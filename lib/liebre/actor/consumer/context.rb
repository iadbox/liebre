module Liebre
  module Actor
    class Consumer
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def queue
          name = queue_config.fetch("name")
          opts = queue_config.fetch("opts", {})

          chan.queue(name, opts).tap do |queue|
            queue.bind(exchange)
          end
        end

      private

        def exchange
          name = exchange_config.fetch("name")
          type = exchange_config.fetch("type")
          opts = exchange_config.fetch("opts", {})

          chan.exchange(name, type, opts)
        end

        def exchange_config
          spec.fetch("exchange")
        end

        def queue_config
          spec.fetch("queue")
        end

        attr_reader :chan, :spec

      end
    end
  end
end
