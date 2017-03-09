module Liebre
  module Actor
    class Context
      class Extensions

        def initialize context, base_class
          @context    = context
          @base_class = base_class
        end

        def call
          build(base, extension_classes)
        end

      private

        def build current, extension_classes
          next_class, *rest = extension_classes

          if next_class
            next_instance = next_class.new(current, context)
            build(next_instance, rest)
          else
            current
          end
        end

        def extension_classes
          context.opts.fetch("extensions", []).map do |class_name|
            Object.const_get(class_name)
          end
        end

        def base
          base_class.new(nil, context)
        end

        attr_reader :context, :base_class

      end
    end
  end
end
