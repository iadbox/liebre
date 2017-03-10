module Liebre
  module Actor
    module RPC
      class Server
        class Base

          def initialize server, resources, context, callback_class
            @server         = server
            @resources      = resources
            @context        = context
            @callback_class = callback_class
          end

          def start
            request_queue.subscribe(OPTS) do |info, meta, payload|
              server.handle(meta, payload)
            end
            response_exchange
          end

          def stop
            request_queue.unsubscribe
            chan.close
          end

          def handle meta, payload
            callback = callback_class.new(server, meta)

            handler.call(payload, meta, callback) do |error|
              callback.failed(error)
            end
          end

          def reply meta, response, opts
            opts = opts.merge :routing_key    => meta.reply_to,
                              :correlation_id => meta.correlation_id

            response_exchange.publish(response, opts)
          end

          def failed _meta, _error
          end

        private

          def request_queue
            resources.request_queue
          end

          def response_exchange
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
