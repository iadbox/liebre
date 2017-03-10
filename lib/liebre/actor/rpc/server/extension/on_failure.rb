module Liebre
  module Actor
    module RPC
      class Server
        module Extension
          class OnFailure

            def self.reply response
              new(true, response)
            end

            def self.no_reply
              new(false)
            end

            def initialize continue, response = nil
              @continue = continue
              @response = response
            end

            def continue?
              @continue
            end

            attr_reader :response

          end
        end
      end
    end
  end
end
