module Liebre
  module Actor
    module RPC
      class Server
        class Handler

          def initialize handler_class, pool
            @handler_class = handler_class
            @pool          = pool
          end

          def call payload, meta, callback
            pool.post do
              run(payload, meta, callback)
            end
          end

        private

          def run payload, meta, callback
            handler = handler_class.new(payload, meta, callback)
            handler.call
          rescue => e
            callback.fail(e)
          end

          attr_reader :handler_class, :pool

        end
      end
    end
  end
end
