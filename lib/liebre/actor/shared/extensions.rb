module Liebre
  module Actor
    module Shared
      class Extensions

        def self.build *args
          builder = new(*args)
          builder.call
        end

        def initialize extension_classes, base_class, chan, context
          @extension_classes = extension_classes
          @base_class        = base_class
          @chan              = chan
          @context           = context
        end

        def call
          build(base, extension_classes)
        end

      private

        def build current, extension_classes
          next_class, *rest = extension_classes

          if next_class
            next_instance = next_class.new(stack, chan, context)
            build(next_instance, rest)
          else
            current
          end
        end

        def base
          @base ||= base_class.new(nil, chan, context)
        end

        attr_reader :extension_classes, :base_class, :chan, :context

      end
    end
  end
end
