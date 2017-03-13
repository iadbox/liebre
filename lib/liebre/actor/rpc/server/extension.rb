module Liebre
  module Actor
    module RPC
      class Server
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

          def handle meta, payload
            stack.handle(meta, payload)
          end

          def reply meta, response, opts
            stack.reply(meta, response, opts)
          end

          def failed meta, error
            stack.failed(meta, error)
          end

        private

          attr_reader :stack, :resources, :context

        end
      end
    end
  end
end
