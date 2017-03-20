module Liebre
  module Adapter
    module Interface
      module Conn

        def start
          raise NotImplementedError, "All adapters must implement connection start() to establish connection"
        end

        def open_channel
          raise NotImplementedError, "All adapters must implement connection open_channel() to start new channels"
        end

        def stop
          raise NotImplementedError, "All adapters must implement connection stop() to disconnect from the server"
        end

      end
    end
  end
end
