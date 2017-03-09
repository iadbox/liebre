module Liebre
  module Actor
    module RPC
      class Client
        class Stack
          module OnReply
            class Continue

              attr_accessor :response

              def initialize response
                @response = response
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