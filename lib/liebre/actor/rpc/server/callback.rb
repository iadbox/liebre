module Liebre
  module Actor
    module RPC
      class Server
        class Callback

          def initialize server, info, meta
            @server = server
            @info   = info
            @meta   = meta
          end

          def reply response, opts = {}
            server.reply(info, meta, response, opts)
          end

          def fail error
            server.fail(info, meta, error)
          end

        private

          attr_reader :server, :info, :meta

        end
      end
    end
  end
end
