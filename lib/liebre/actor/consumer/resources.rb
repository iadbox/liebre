module Liebre
  module Actor
    class Consumer
      class Resources

        attr_reader :declare, :spec

        def initialize declare, spec
          @declare = declare
          @spec    = spec
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
          spec.fetch("exchange")
        end

        def queue_config
          spec.fetch("queue")
        end

        def bind_config
          spec.fetch("bind", {})
        end

      end
    end
  end
end
