module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnFailure
            class Reply

              attr_accessor :response, :opts

              def initialize response, opts
                @response = response
                @opts     = opts
              end

              def respond?
                true
              end

            end
          end
        end
      end
    end
  end
end
