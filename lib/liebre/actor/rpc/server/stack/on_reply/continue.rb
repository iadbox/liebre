module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnReply
            class Continue

              attr_accessor :response, :opts

              def initialize response, opts
                @response = response
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
