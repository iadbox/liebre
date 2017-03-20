module Liebre
  module Adapter
    class Bunny
      class Exchange
        include Interface::Exchange

        attr_reader :exchange

        def initialize exchange
          @exchange = exchange
        end

        def publish payload, opts = {}
          exchange.publish(payload, opts)
        end

      end
    end
  end
end
