module Liebre
  module Actor
    module RPC
      class Server
        module Extension

          def initialize stack, context
            @stack   = stack
            @context = context
          end

          def start
            stack.start
          end

          def on_request tag, payload, opts, callback
            stack.on_request(tag, payload, opts, callback)
          end

          def on_reply tag, response, opts
            stack.on_reply(tag, response, opts)
          end

          def after_reply tag, response, opts
            stack.after_reply(tag, response)
          end

          def on_failure tag, error
            stack.on_failure(tag, error)
          end

          def stop
            stack.stop
          end

        private

          def request
            Stack::OnRequest
          end

          def reply
            Stack::OnReply
          end

          def failure
            Stack::OnFailure
          end

          attr_reader :stack, :context

        end
      end
    end
  end
end
