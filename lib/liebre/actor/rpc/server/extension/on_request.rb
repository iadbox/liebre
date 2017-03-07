module Liebre
  module Actor
    module RPC
      class Client
        module Extension
          class OnRequest

            def self.handle payload, opts
              new(true, false, payload, opts)
            end

            def self.reply response
              new(false, true, payload)
            end

            def self.no_reply
              new(false, false)
            end

            def initialize continue, reply, payload = nil, opts = nil
              @continue = continue
              @reply    = reply

              @payload = payload
              @opts    = opts
            end

            def continue?
              @continue
            end

            def reply?
              @reply
            end

            attr_reader :payload, :opts

          end
        end
      end
    end
  end
end
