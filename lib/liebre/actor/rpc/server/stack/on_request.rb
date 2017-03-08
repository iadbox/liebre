require 'liebre/actor/rpc/server/stack/on_request/continue'
require 'liebre/actor/rpc/server/stack/on_request/cancel'

module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnRequest

            def self.continue response, opts, callback
              Continue.new(response, opts, callback)
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
