module Liebre
  module Adapter
    class Bunny
      class Queue
        include Interface::Queue

        attr_reader :queue

        def initialize queue
          @queue = queue
        end

        def name
          queue.name
        end

        def bind exchange, opts = {}
          bunny_exchange = exchange.exchange

          queue.bind(bunny_exchange, opts)
        end

        def ack info, opts = {}
          multiple = opts.fetch(:multiple, false)

          channel.ack(info.delivery_tag, multiple)
        end

        def nack info, opts = {}
          multiple = opts.fetch(:multiple, false)
          requeue  = opts.fetch(:requeue, false)

          channel.nack(info.delivery_tag, multiple, requeue)
        end

        def reject info, opts = {}
          requeue  = opts.fetch(:requeue, false)

          channel.reject(info.delivery_tag, requeue)
        end

        def get opts = {}, &block
          queue.get(opts, &block)
        end

        def subscribe opts = {}, &block
          queue.subscribe(opts, &block)
        end

      private

        def channel
          queue.channel
        end

      end
    end
  end
end
