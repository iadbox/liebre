module Liebre
  module Actor
    module RPC
      class Client
        module Extension

          def initialize stack, resources, context
            @stack     = stack
            @resources = resources
            @context   = context
          end

          def start
            stack.start
          end

          def stop
            stack.stop
          end

          def request payload, opts, timeout
            stack.request(payload, opts, timeout)
          end

          def reply meta, response
            stack.reply(meta, response)
          end

          def expire
            stack.expire
          end

        private

          attr_reader :stack, :resources, :context

        end
      end
    end
  end
end
