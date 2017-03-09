require 'concurrent'

module Liebre
  module Actor
    class Context
      class Handler

        DEFAULT_POOL_SIZE = 5

        def initialize opts
          @opts = opts
        end

        def call *args, &block
          pool.post { handle(args, block) }
        end

      private

        def handle args, block
          handler = handler_class.new(*args)
          handler.call
        rescue => error
          block.call(error)
        end

        def pool
          @pool ||= Concurrent::FixedThreadPool.new(pool_size)
        end

        def pool_size
          opts.fetch("pool_size", DEFAULT_POOL_SIZE)
        end

        def handler_class
          @handler_class ||= begin
            class_name = opts.fetch("handler_class")

            Object.const_get(class_name)
          end
        end

        attr_reader :opts

      end
    end
  end
end
