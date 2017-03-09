module Liebre
  module Actor
    class Publisher
      class Resources

        attr_reader :declare, :spec

        def initialize declare, spec
          @declare = declare
          @spec    = spec
        end

        def exchange
          @exchange ||= declare.exchange(exchange_config)
        end

      private

        def exchange_config
          spec.fetch("exchange")
        end

      end
    end
  end
end
