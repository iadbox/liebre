module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          class Base
            include Extension

            def initialize _stack, _context
            end

            def start
            end

            def on_request _tag, payload, opts
              request.continue(payload, opts)
            end

            def after_request _tag, _payload, _opts
            end

            def on_reply _tag, response
              reply.continue(response)
            end

            def after_reply _tag, response
            end

            def stop
            end

          end
        end
      end
    end
  end
end
