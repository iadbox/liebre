module Liebre
  class Engine
    class Starter
      class Publisher

        ACTOR = Liebre::Actor::Publisher

        def initialize bridge, opts
          @bridge = bridge
          @opts   = opts
        end

        def call
          starter = Shared::Actor.new(bridge, opts, ACTOR)
          starter.call
        end

      private

        attr_reader :bridge, :opts

      end
    end
  end
end
