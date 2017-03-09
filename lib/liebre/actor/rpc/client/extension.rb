module Liebre
  module Actor
    module RPC
      class Client
        module Extension

          attr_reader :stack, :context

          def initialize stack, context
            @stack   = stack
            @context = context
          end

          def start
            stack.start
          end

          def on_request tag, payload, opts
            stack.on_request(tag, payload, opts)
          end

          def after_request tag, payload, opts
            stack.after_request(tag, payload, opts)
          end

          def on_reply tag, response
            stack.on_reply(tag, response)
          end

          def after_reply tag, response
            stack.after_reply(tag, response)
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

        end
      end
    end
  end
end
