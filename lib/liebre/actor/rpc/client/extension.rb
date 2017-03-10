require 'liebre/actor/rpc/client/extension/on_request'
require 'liebre/actor/rpc/client/extension/on_reply'
require 'liebre/actor/rpc/client/extension/on_expire'

module Liebre
  module Actor
    module RPC
      class Client
        module Extension

          def initialize _chan, _context
          end

          def start
          end

          def on_request payload, opts
            request.continue(payload, opts)
          end

          def after_request _payload, _opts
          end

          def on_reply response
            reply.reply(response)
          end

          def on_expire
            expire.no_reply
          end

          def after_reply response
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

          def expire
            OnExpire
          end

        end
      end
    end
  end
end
