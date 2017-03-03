module Liebre
  module Actor
    class Publisher
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def exchange
          name = exchange_config.fetch("name")
          type = exchange_config.fetch("type")
          opts = exchange_config.fetch("opts", {})

          chan.exchange(name, type, opts)
        end

      private

        def exchange_config
          spec.fetch("exchange")
        end

        attr_reader :chan, :spec

      end
    end
  end
end
