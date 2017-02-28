module Liebre
  module Actor
    class Consumer
      class Callback

        def initialize consumer, info
          @consumer = consumer
          @info     = info
        end

        def ack opts = {}
          consumer.ack(info, opts)
        end

        def nack opts = {}
          consumer.nack(info, opts)
        end

        def reject opts = {}
          consumer.reject(info, opts)
        end

      private

        attr_reader :consumer, :info

      end
    end
  end
end
