module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          module OnRequest
            class Continue

              attr_accessor :payload, :opts

              def initialize payload, opts
                @payload  = payload
                @opts     = opts
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
