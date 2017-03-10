require 'concurrent'

require 'liebre/actor/consumer/resources'
require 'liebre/actor/consumer/callback'

module Liebre
  module Actor
    class Consumer
      include Concurrent::Async

      OPTS = {:block => false, :manual_ack => true}

      def initialize context
        super()

        @context = context
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def consume(info, meta, payload) async.__consume__(info, meta, payload); end

      def ack(info, opts = {})    async.__ack__(info, opts);     end
      def nack(info, opts = {})   async.__nack__(info, opts);    end
      def reject(info, opts = {}) async.__reject__(info, opts);  end
      def failed(info, error)     async.__failed__(info, error); end

      def __start__
        queue.subscribe(OPTS) do |info, meta, payload|
          consume(info, meta, payload)
        end
      end

      def __stop__
        queue.unsubscribe
        chan.close
      end

      def __consume__ info, meta, payload
        callback = Callback.new(self, info)

        handler.call(payload, meta, callback) do |error|
          callback.failed(error)
        end
      end

      def __ack__ info, opts = {}
        queue.ack(info, opts)
      end

      def __nack__ info, opts = {}
        queue.nack(info, opts)
      end

      def __reject__ info, opts = {}
        queue.reject(info, opts)
      end

      def __failed__ info, error
        queue.reject(info, {})
      end

    private

      def queue
        resources.queue
      end

      def chan
        context.chan
      end

      def handler
        context.handler
      end

      def resources
        @resources ||= Resources.new(context)
      end

      attr_reader :context

    end
  end
end
