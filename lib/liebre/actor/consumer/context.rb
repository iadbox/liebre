module Liebre
  module Actor
    class Consumer
      class Context

        attr_reader :chan, :spec

        def initialize chan, spec
          @chan = chan
          @spec = spec
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

        def declare
          @declare ||= Shared::Declare.new(chan)
        end

      end
    end
  end
end
