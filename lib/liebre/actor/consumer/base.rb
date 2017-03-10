module Liebre
  module Actor
    class Consumer
      class Base

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
        end

        def stop
          queue.unsubscribe
          chan.close
        end

        def consume info, meta, payload
          callback = callback_class.new(consumer, info)

          handler.call(payload, meta, callback) do |error|
            callback.failed(error)
          end
        end

        def callback info, action, opts
          case action
            when :ack    then queue.ack(info, opts)
            when :nack   then queue.nack(info, opts)
            when :reject then queue.reject(info, opts)
          end
        end

        def failed info, _error
          queue.reject(info, {})
        end

      private

        def queue
          resources.queue
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
