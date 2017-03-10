module Liebre
  module Actor
    class Publisher
      module Extension
        class OnPublication

          def self.continue payload, opts
            new(true, payload, opts)
          end

          def self.cancel
            new(false)
          end

          def initialize continue, payload = nil, opts = nil
            @continue = continue

            @payload = payload
            @opts    = opts
          end

          def continue?
            @continue
          end

          attr_reader :payload, :opts

        end
      end
    end
  end
end
