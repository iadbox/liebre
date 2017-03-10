module Liebre
  module Actor
    class Publisher
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def exchange
          @exchange ||= declare.exchange(exchange_config)
        end

      private

        def exchange_config
          spec.fetch("exchange")
        end

        def declare
          @declare ||= Shared::Declare.new(chan)
        end

        attr_reader :chan, :spec

      end
    end
  end
end
