module Liebre
  module Actor
    class Publisher
      class Stack
        module OnPublication
          class Continue

            attr_accessor :payload, :opts

            def initialize payload, opts
              @payload = payload
              @opts    = opts
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
