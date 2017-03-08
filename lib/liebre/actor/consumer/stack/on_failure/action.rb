module Liebre
  module Actor
    class Consumer
      class Stack
        module OnFailure
          class Action

            attr_accessor :action, :opts

            def initialize action, opts
              @action = action
              @opts   = opts
            end

          end
        end
      end
    end
  end
end
