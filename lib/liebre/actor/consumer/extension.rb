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

        def on_consume tag, payload, meta, callback
          stack.on_consume(tag, payload, meta, callback)
        end

        def after_cancel tag, payload, meta, callback
          stack.after_cancel(tag, payload, meta, callback)
        end

        def on_failure tag, error
          stack.on_failure(tag, error)
        end

        def on_callback tag, action, opts
          stack.on_callback(tag, action, opts)
        end

        def after_callback tag, action, opts
          stack.after_callback(tag, action, opts)
        end

        def stop
          stack.stop
        end

      private

        def consume
          Stack::OnConsume
        end

        def failure
          Stack::OnFailure
        end

        def callback
          Stack::OnCallback
        end

        attr_reader :stack, :context

      end
    end
  end
end
