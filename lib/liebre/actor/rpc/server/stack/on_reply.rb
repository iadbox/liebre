require 'liebre/actor/rpc/server/stack/on_reply/continue'
require 'liebre/actor/rpc/server/stack/on_reply/cancel'

module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnReply

            def self.continue response, opts
              Continue.new(response, opts)
            end

            def self.cancel
              Cancel.instance
            end

          end
        end
      end
    end
  end
end
