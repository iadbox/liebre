require 'concurrent'

require 'liebre/actor/rpc/server/resources'
require 'liebre/actor/rpc/server/callback'

module Liebre
  module Actor
    module RPC
      class Server
        include Concurrent::Async

        OPTS = {:block => false, :manual_ack => false}

        def initialize context
          super()

          @context = context
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def handle(meta, payload) async.__handle__(meta, payload); end

        def reply(meta, response, opts = {}) async.__reply__(meta, response, opts); end
        def failed(meta, error)              async.__failed__(meta, error);         end

        def __start__
          queue.subscribe(OPTS) do |info, meta, payload|
            handle(meta, payload)
          end
          exchange
        end

        def __stop__
          queue.unsubscribe
          chan.close
        end

        def __handle__ meta, payload
          callback = Callback.new(self, meta)

          handler.call(payload, meta, callback) do |error|
            callback.failed(error)
          end
        end

        def __reply__ meta, response, opts = {}
          opts = opts.merge :routing_key    => meta.reply_to,
                            :correlation_id => meta.correlation_id

          exchange.publish(response, opts)
        end

        def __failed__ meta, error
        end

      private

        def queue
          resources.request_queue
        end

        def exchange
          resources.response_exchange
        end

        def chan
          context.chan
        end

        def handler
          context.handler
        end

        def resources
          @resources ||= Resources.new(context)
        end

        attr_reader :context

      end
    end
  end
end
