module Liebre
  module Actor
    class Consumer
      module Extension
        class OnConsume

          def self.continue message, meta, callback
            new(true, message, meta, callback)
          end

          def self.cancel
            new(false)
          end

          def initialize continue, message = nil, meta = nil, callback = nil
            @continue = continue

            @message  = message
            @meta     = meta
            @callback = callback
          end

          def continue?
            @continue
          end

          attr_reader :message, :meta, :callback

        end
      end
    end
  end
end
