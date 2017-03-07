module Liebre
  module Actor
    module RPC
      class Client
        module Extension
          class OnRequest

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
end
