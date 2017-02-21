module Liebre
  module Adapter
    module Interface
      module Chan

        def exchange name, opts
          raise NotImplementedError, "All adapters must implement channel exchange(name, opts) to declare and build exchanges"
        end

        def queue name, opts
          raise NotImplementedError, "All adapters must implement channel queue(name, opts) to declare and build queues"
        end

        def close
          raise NotImplementedError, "All adapters must implement channel close() to close a channel"
        end

      end
    end
  end
end
