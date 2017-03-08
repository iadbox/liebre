module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnRequest
            class Continue

              attr_accessor :payload, :meta, :callback

              def initialize payload, meta, callback
                @payload  = payload
                @meta     = meta
                @callback = callback
              end

              def continue?
                true
              end

            end
          end
        end
      end
    end
  end
end
