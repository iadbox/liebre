module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          class Base
            include Extension

            def start
            end

            def on_request _tag, payload, opts, callback
              request.continue(payload, opts, callback)
            end

            def on_reply _tag, response, opts
              reply.continue(response, opts)
            end

            def after_reply _tag, _response, _opts
            end

            def on_failure _tag, _error
              failure.no_reply()
            end

            def stop
            end

          end
        end
      end
    end
  end
end
