require 'liebre/actor/consumer/stack/on_callback/action'

module Liebre
  module Actor
    class Consumer
      class Stack
        module OnCallback

          def self.do action, opts
            Action.new(action, opts)
          end

          def self.ack opts
            Action.new(:ack, opts)
          end

          def self.nack opts
            Action.new(:nack, opts)
          end

          def self.reject opts
            Action.new(:reject, opts)
          end

        end
      end
    end
  end
end
