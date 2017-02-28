require 'concurrent'

require 'liebre/rpc/client/context'
require 'liebre/rpc/client/pending'

module Liebre
  module RPC
    class Client
      include Concurrent::Async

      TIMEOUT         = 5
      OPTS            = {:block => false, :manual_ack => false}
      EXPIRE_INTERVAL = 60

      def initialize chan, spec
        super()

        @chan = chan
        @spec = spec
      end

      def start() async.__start__(); end
      def stop()  async.__stop__(); end

      def request payload, opts = {}, timeout = TIMEOUT
        call_ivar     = await.__request__(payload, opts, timeout)
        response_ivar = call_ivar.value

        response_ivar.value(timeout)
      end

      def __start__
        response_queue.subscribe(OPTS) do |_info, meta, payload|
          async.__handle_response__(meta, payload)
        end
        request_exchange

        context.recurrent_task(EXPIRE_INTERVAL) do
          async.__expire__
        end
      end

      def __request__ payload, opts = {}, timeout = TIMEOUT
        pending.add(timeout) do |correlation_id|
          opts = opts.merge :reply_to       => response_queue.name,
                            :correlation_id => correlation_id

          request_exchange.publish(payload, opts)
        end
      end

      def __handle_response__ meta, response
        pending.finish(meta.correlation_id, response)
      end

      def __expire__
        pending.expire
      end

      def __stop__
        response_queue.unsubscribe
      end

    private

      def response_queue
        context.response_queue
      end

      def request_exchange
        context.request_exchange
      end

      def context
        @context ||= Context.new(chan, spec)
      end

      def pending
        @pending ||= Pending.new
      end

      attr_reader :chan, :spec, :handler_class, :pool

    end
  end
end
