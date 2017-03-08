module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnReply
            class Cancel

              def instance
                @instance ||= new
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
