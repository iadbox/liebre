module Liebre
  module Actor
    class Consumer
      class Stack
        module OnConsume
          class Continue

            attr_accessor :payload, :meta, :callback

            def initialize payload, meta, callback
              @payload  = payload
              @meta     = meta
              @callback = callback
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
