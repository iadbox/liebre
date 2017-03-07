require 'concurrent'

require 'liebre/actor/rpc/server/context'
require 'liebre/actor/rpc/server/callback'

module Liebre
  module Actor
    module RPC
      class Server
        include Concurrent::Async

        OPTS = {:block => false, :manual_ack => false}

        def initialize chan, spec, handler_class, pool
          super()

          @chan          = chan
          @spec          = spec
          @handler_class = handler_class
          @pool          = pool
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def reply(meta, response, opts = {}) async.__reply__(meta, response, opts); end

        def __start__
          queue.subscribe(OPTS) do |info, meta, payload|
            async.__handle_request__(meta, payload)
          end
          exchange
        end

        def __stop__
          queue.unsubscribe
          chan.close
        end

        def __reply__ meta, response, opts = {}
          opts = opts.merge :routing_key    => meta.reply_to,
                            :correlation_id => meta.correlation_id

          exchange.publish(response, opts)
        end

        def __handle_request__ meta, payload
          callback = Callback.new(self, meta)

          pool.post { handle(payload, meta, callback) }
        end

      private

        def handle payload, meta, callback
          handler = handler_class.new(payload, meta, callback)
          handler.call
        rescue => e
          # TODO: Log error
        end

        def queue
          context.request_queue
        end

        def exchange
          context.response_exchange
        end

        def context
          @context ||= Context.new(chan, spec)
        end

        attr_reader :chan, :spec, :handler_class, :pool

      end
    end
  end
end
