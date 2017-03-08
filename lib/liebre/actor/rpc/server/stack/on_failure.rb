require 'liebre/actor/rpc/server/stack/on_failure/reply'
require 'liebre/actor/rpc/server/stack/on_failure/no_reply'

module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnFailure

            def self.reply response, opts = {}
              Reply.new(response, opts)
            end

            def self.no_reply
              NoReply.instance
            end

          end
        end
      end
    end
  end
end
