module Liebre
  module Actor
    class Publisher
      class Stack
        module OnPublication
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
