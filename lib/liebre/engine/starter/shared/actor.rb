module Liebre
  class Engine
    class Starter
      module Shared
        class Actor

          def initialize bridge, opts, actor_class
            @bridge      = bridge
            @opts        = opts
            @actor_class = actor_class
          end

          def call
            build.tap(&:start)
          end

        private

          def build
            actor_class.new(channel, resources)
          end

          def channel
            bridge.open_channel(opts)
          end

          def resources
            opts.fetch("resources", {})
          end

          attr_reader :bridge, :opts, :actor_class

        end
      end
    end
  end
end
