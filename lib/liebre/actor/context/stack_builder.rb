module Liebre
  module Actor
    class Context
      class StackBuilder

        def initialize context, opts, resources, base
          @context   = context
          @opts      = opts
          @resources = resources
          @base      = base
        end

        def call
          build(base, extension_classes)
        end

      private

        def build stack, extension_classes
          current_class, *rest = extension_classes

          if current_class.nil?
            stack
          else
            current = current_class.new(stack, resources, context)
            build(current, rest)
          end
        end

        def extension_classes
          opts.fetch(:extensions, []).reverse
        end

        attr_reader :context, :opts, :resources, :base

      end
    end
  end
end
