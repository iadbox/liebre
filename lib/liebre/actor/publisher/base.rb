require 'concurrent'

require 'liebre/actor/publisher/resources'

module Liebre
  module Actor
    class Publisher
      class Base

        def initialize exchange, chan
          @exchange = exchange
          @chan     = chan
        end

        def start
          exchange
        end

        def publish payload, opts
          exchange.publish(payload, opts)
        end

        def stop
          chan.stop
        end

      private

        attr_reader :exchange

      end
    end
  end
end
