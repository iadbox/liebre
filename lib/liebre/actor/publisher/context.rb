module Liebre
  module Actor
    class Publisher
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def exchange
          @exchange ||= begin
            name = exchange_config.fetch("name")
            type = exchange_config.fetch("type")
            opts = exchange_config.fetch("opts", {})

            chan.exchange(name, type, symbolize(opts))
          end
        end

      private

        def exchange_config
          spec.fetch("exchange")
        end

        def symbolize opts
          opts.reduce({}) { |new, (key, value)| new.merge!(key.to_sym => value) }
        end

        attr_reader :chan, :spec

      end
    end
  end
end
