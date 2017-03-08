module Liebre
  module Actor
    class Consumer
      class Stack
        module OnConsume
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
