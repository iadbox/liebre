module Liebre
  class Engine
    class Starter
      module RPC
        class Client

          ACTOR = Liebre::Actor::RPC::Client

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
end
