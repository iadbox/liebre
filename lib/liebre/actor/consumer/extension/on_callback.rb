module Liebre
  module Actor
    class Consumer
      module Extension
        class OnCallback

          def self.do action, opts
            new(action, opts)
          end

          def self.ack opts
            new(:ack, opts)
          end

          def self.nack opts
            new(:nack, opts)
          end

          def self.reject opts
            new(:reject, opts)
          end

          def initialize action, opts
            @action = action
            @opts   = opts
          end

          attr_reader :action, :opts

        end
      end
    end
  end
end
