module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          module OnRequest
            class Reply

              attr_accessor :response

              def initialize response
                @response = response
              end

              def continue?
                false
              end

            end
          end
        end
      end
    end
  end
end
