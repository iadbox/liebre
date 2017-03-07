module Liebre
  module Actor
    class Publisher
      module Extension

        attr_reader :stack, :context

        def initialize stack, context
          @stack   = stack
          @context = context
        end

        def start
          stack.start
        end

        def on_publication payload, opts
          stack.on_publication(payload, opts)
        end

        def after_publish payload, opts
          stack.after_publish(payload, opts)
        end

        def after_cancel payload, opts
          stack.after_cancel(payload, opts)
        end

        def stop
          stack.stop
        end

      private

        def publication
          Stack::OnPublication
        end

      end
    end
  end
end
