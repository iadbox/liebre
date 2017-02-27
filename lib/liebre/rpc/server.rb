require 'liebre/rpc/server/context'

module Liebre
  module RPC
    class Server

      OPTS = {:block => false, :manual_ack => false}

      def initialize chan, spec, handler_class, pool
        super()

        @chan          = chan
        @spec          = spec
        @handler_class = handler_class
        @pool          = pool
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def reply(meta, response) async.__reply__(meta, response); end

      def __start__
        queue.subscribe(OPTS) do |info, meta, payload|
          pool.post { run(payload, meta) }
        end
      end

      def __reply__ meta, response
        opts = {:routing_key    => meta.reply_to,
                :correlation_id => meta.correlation_id}

        exchange.publish(response, opts)
      end

      def __stop__
        queue.unsubscribe
      end

    private

      def run payload, meta
        handler  = handler_class.new(payload, meta)
        response = handler.call

        reply(meta, response)
      rescue => e
        # TODO: Log error
      end

      def queue
        @queue ||= context.request_queue
      end

      def exchange
        @exchange ||= context.exchange
      end

      def context
        @context ||= Context.new(chan, spec)
      end

      attr_reader :chan, :spec, :handler_class, :pool

    end
  end
end
