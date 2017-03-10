module Liebre
  module Actor
    class Consumer
      module Extension

        def initialize stack, context
          @stack   = stack
          @context = context
        end

        def start
          stack.start
        end

        def on_consume payload, meta, callback
          stack.on_consume(payload, meta, callback)
        end

        def after_cancel payload, meta, callback
          stack.after_cancel(payload, meta, callback)
        end

        def on_callback action, opts
          stack.on_callback(action, opts)
        end

        def after_callback action, opts
          stack.after_callback(action, opts)
        end

        def stop
          stack.stop
        end

      private

        def consume
          Stack::OnConsume
        end

        def callback
          Stack::OnCallback
        end

      end
    end
  end
end
