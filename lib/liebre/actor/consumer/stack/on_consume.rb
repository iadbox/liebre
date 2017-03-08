require 'liebre/actor/consumer/stack/on_consume/continue'
require 'liebre/actor/consumer/stack/on_consume/cancel'

module Liebre
  module Actor
    class Consumer
      class Stack
        module OnConsume

          def self.continue payload, meta, callback
            Continue.new(payload, meta, callback)
          end

          def self.cancel
            Cancel.instance
          end

        end
      end
    end
  end
end
