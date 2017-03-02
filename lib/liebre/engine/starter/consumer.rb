module Liebre
  class Engine
    class Starter
      class Consumer

        ACTOR = Liebre::Actor::Consumer

        def initialize bridge, opts
          @bridge = bridge
          @opts   = opts
        end

        def call
          starter = Shared::PooledActor.new(bridge, opts, ACTOR)
          starter.call
        end

      private

        attr_reader :bridge, :opts

      end
    end
  end
end
