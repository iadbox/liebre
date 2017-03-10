module Liebre
  module Actor
    class Publisher
      class Stack
        class Base
          include Extension

          def initialize _stack, _chan, _context
          end

          def start
          end

          def on_publication payload, opts
            publication.continue(payload, opts)
          end

          def after_publish _payload, _opts
          end

          def after_cancel _payload, _opts
          end

          def stop
          end

        end
      end
    end
  end
end
