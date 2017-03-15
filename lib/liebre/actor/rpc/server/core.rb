module Liebre
  module Actor
    module RPC
      class Server
        class Core
          include Concurrent::Async

          OPTS = {:block => false, :manual_ack => false}

          def initialize server, resources, context, callback_class
            @server         = server
            @resources      = resources
            @context        = context
            @callback_class = callback_class
          end

          def start
            queue.subscribe(OPTS) do |info, meta, payload|
              server.handle(meta, payload)
            end
            exchange
          end

          def stop
            queue.unsubscribe
            chan.close
          end

          def handle meta, payload
            callback = callback_class.new(server, meta)

            handler.call(payload, meta, callback) do |error|
              callback.failed(error)
            end
          end

          def reply meta, response, opts = {}
            opts = opts.merge :routing_key    => meta.reply_to,
                              :correlation_id => meta.correlation_id

            exchange.publish(response, opts)
          end

          def failed meta, error
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

          attr_reader :server, :resources, :context, :callback_class

        end
      end
    end
  end
end
