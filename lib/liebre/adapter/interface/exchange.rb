module Liebre
  module Adapter
    module Interface
      module Exchange

        def publish payload, opts
          raise NotImplementedError, "All adapters must implement exchange publish(payload, opts) to publish messages"
        end

      end
    end
  end
end
