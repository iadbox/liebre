module Liebre
  module Actor
    class Consumer
      class Stack
        class Base
          include Extension

          def initialize _stack, _context
          end

          def start
          end

          def on_consume _tag, payload, meta, callback
            consume.continue(payload, meta, callback)
          end

          def after_cancel _tag, _message, _meta, _callback
          end

          def on_failure _tag, _error
            callback.reject()
          end

          def on_callback _tag, action, opts
            callback.do(action, opts)
          end

          def after_callback _tag, _action, _opts
          end

          def stop
          end

        end
      end
    end
  end
end
