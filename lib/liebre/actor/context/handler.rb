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
          @pool ||= begin
            size = opts.fetch(:pool_size, DEFAULT_POOL_SIZE)

            Concurrent::FixedThreadPool.new(size)
          end
        end

        def handler_class
          @handler_class ||= opts.fetch(:handler)
        end

        attr_reader :opts

      end
    end
  end
end
