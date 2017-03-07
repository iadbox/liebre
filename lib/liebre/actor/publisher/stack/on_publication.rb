require 'liebre/actor/publisher/stack/on_publication/continue'
require 'liebre/actor/publisher/stack/on_publication/cancel'

module Liebre
  module Actor
    class Publisher
      class Stack
        module OnPublication

          def self.continue payload, opts
            Continue.new(payload, opts)
          end

          def self.cancel
            Cancel.instance
          end

        end
      end
    end
  end
end
