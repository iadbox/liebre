module Liebre
  module Actor
    class Publisher
      module Extension

        def initialize stack, resources, context
          @stack     = stack
          @resources = resources
          @context   = context
        end

        def start
          stack.start
        end

        def publish payload, opts
          stack.publish(payload, opts)
        end

        def stop
          stack.stop
        end

      private

        attr_reader :stack, :resources, :context

      end
    end
  end
end
