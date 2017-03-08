module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnRequest
            class Cancel

              def self.instance
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
