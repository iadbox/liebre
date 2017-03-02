module Liebre
  class Engine
    class Starter
      module Shared
        class PooledActor

          DEFAULT_POOL_SIZE = 5

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
            actor_class.new(channel, resources, handler_class, pool)
          end

          def pool
            Concurrent::FixedThreadPool.new(pool_size)
          end

          def channel
            bridge.open_channel(opts)
          end

          def pool_size
            opts.fetch("pool_size", DEFAULT_POOL_SIZE)
          end

          def handler_class
            class_name = opts.fetch("handler_class")

            Object.const_get(class_name)
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
