module Liebre
  module Actor
    class Consumer
      class Resources

        def initialize context
          @context = context
        end

        def queue
          @queue ||= declare.queue(queue_config).tap do |queue|
            declare.bind(queue, exchange, bind_config)
          end
        end

        def exchange
          @exchange ||= declare.exchange(exchange_config)
        end

      private

        def exchange_config
          spec.fetch(:exchange)
        end

        def queue_config
          spec.fetch(:queue)
        end

        def bind_config
          spec.fetch(:bind, {})
        end

        def spec
          context.spec
        end

        def declare
          context.declare
        end

        attr_reader :context

      end
    end
  end
end
