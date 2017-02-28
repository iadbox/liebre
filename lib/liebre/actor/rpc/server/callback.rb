module Liebre
  module Actor
    module RPC
      class Server
        class Callback

          def initialize server, meta
            @server = server
            @meta   = meta
          end

          def reply response, opts = {}
            server.reply(meta, response, opts)
          end

        private

          attr_reader :server, :meta

        end
      end
    end
  end
end
