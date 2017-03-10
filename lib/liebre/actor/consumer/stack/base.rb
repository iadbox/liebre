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

          def on_consume payload, meta, callback
            consume.continue(payload, meta, callback)
          end

          def after_cancel _message, _meta, _callback
          end

          def on_callback action, opts
            callback.do(action, opts)
          end

          def after_callback _action, _opts
          end

          def stop
          end

        end
      end
    end
  end
end
