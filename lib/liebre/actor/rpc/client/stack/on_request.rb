require 'liebre/actor/rpc/client/stack/on_request/continue'
require 'liebre/actor/rpc/client/stack/on_request/reply'

module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          module OnRequest

            def self.continue payload, opts
              Continue.new(payload, opts)
            end

            def self.reply response
              Reply.new(response)
            end

          end
        end
      end
    end
  end
end
