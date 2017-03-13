module Liebre
  module Actor
    class Consumer
      module Extension

        def initialize stack, resources, context
          @stack     = stack
          @resources = resources
          @context   = context
        end

        def start
          stack.start
        end

        def stop
          stack.stop
        end

        def consume info, meta, payload
          stack.consume(info, meta, payload)
        end

        def callback info, action, opts
          stack.callback(info, action, opts)
        end

        def failed info, error
          stack.failed(info, error)
        end

      private

        attr_reader :stack, :resources, :context

      end
    end
  end
end
