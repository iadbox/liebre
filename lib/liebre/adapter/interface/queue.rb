module Liebre
  module Adapter
    module Interface
      module Queue

        def name
          raise NotImplementedError, "All adapters must implement queue name() to get the name of the queue"
        end

        def bind exchange, opts = {}
          raise NotImplementedError, "All adapters must implement queue bind(exchange, opts) to bind the queue to an exchange"
        end

        def get opts = {}, &block
          raise NotImplementedError, "All adapters must implement queue get(opts, &block) to get messages"
        end

        def subscribe opts = {}, &block
          raise NotImplementedError, "All adapters must implement queue subscribe(opts, block) consume messajes constantly"
        end

        def ack info, opts = {}
          raise NotImplementedError, "All adapters must implement queue ack(info, opts) to ack messages"
        end

        def nack info, opts = {}
          raise NotImplementedError, "All adapters must implement queue nack(info, opts) to nack messages"
        end

        def reject info, opts = {}
          raise NotImplementedError, "All adapters must implement queue reject(info, opts) to reject messages"
        end

      end
    end
  end
end
