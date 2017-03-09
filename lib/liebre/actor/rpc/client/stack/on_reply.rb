require 'liebre/actor/rpc/client/stack/on_reply/continue'

module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          module OnReply

            def self.continue response
              Continue.new(response)
            end

          end
        end
      end
    end
  end
end
