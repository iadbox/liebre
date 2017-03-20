module Liebre
  module Actor
    class Consumer
      class Core

        OPTS = {:block => false, :manual_ack => true}

        def initialize consumer, resources, context, callback_class
          @consumer       = consumer
          @resources      = resources
          @context        = context
          @callback_class = callback_class
        end

        def start
          queue.subscribe(OPTS) do |info, meta, payload|
            consumer.consume(info, meta, payload)
          end
          dead_queue
        end

        def stop
          chan.close
        end

        def consume info, meta, payload
          callback = callback_class.new(consumer, info)

          handler.call(payload, meta, callback) do |error|
            callback.failed(error)
          end
        end

        def ack(info, opts)    queue.ack(info, opts);    end
        def nack(info, opts)   queue.nack(info, opts);   end
        def reject(info, opts) queue.reject(info, opts); end

        def failed info, error
          queue.reject(info, {})
        end

        def clean
          queue.delete
          exchange.delete
          dead_queue.delete
          dead_exchange.delete
        end

      private

        def queue
          resources.queue
        end

        def exchange
          resources.exchange
        end

        def dead_queue
          resources.dead_queue
        end

        def dead_exchange
          resources.dead_exchange
        end

        def chan
          context.chan
        end

        def handler
          context.handler
        end

        attr_reader :consumer, :resources, :context, :callback_class

      end
    end
  end
end
