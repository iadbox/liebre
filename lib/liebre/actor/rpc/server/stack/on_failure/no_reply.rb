module Liebre
  module Actor
    module RPC
      class Server
        class Stack
          module OnFailure
            class NoReply

              def self.instance
                @instance ||= new
              end

              def respond?
                false
              end

            end
          end
        end
      end
    end
  end
end
