module Liebre
  module Actor
    class Publisher
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def exchange
          name = spec.exchange_name
          opts = spec.exchange_opts

          chan.exchange(name, opts)
        end

      private

        attr_reader :chan, :spec

      end
    end
  end
end
