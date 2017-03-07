require 'liebre/actor/rpc/server/extension/on_request'
require 'liebre/actor/rpc/server/extension/on_reply'
require 'liebre/actor/rpc/server/extension/on_expire'

module Liebre
  module Actor
    module RPC
      class Server
        module Extension

          def initialize _chan, _context
          end

          def start
          end

          def on_request payload, opts
            request.handle(payload, opts)
          end

          def on_reply response
            reply.reply(response)
          end

          def after_reply response
          end

          def on_failure
            failure.no_reply
          end

          def stop
          end

        private

          def request
            OnRequest
          end

          def reply
            OnReply
          end

          def failure
            OnFailure
          end

        end
      end
    end
  end
end
