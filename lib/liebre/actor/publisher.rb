require 'concurrent'

require 'liebre/actor/publisher/resources'

module Liebre
  module Actor
    class Publisher
      include Concurrent::Async

      def initialize context
        super()

        @context = context
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def publish(payload, opts = {}) async.__publish__(payload, opts); end

      def __start__
        exchange
      end

      def __stop__
        chan.close
      end

      def __publish__ payload, opts = {}
        exchange.publish(payload, opts)
      end

    private

      def exchange
        resources.exchange
      end

      def chan
        context.chan
      end

      def resources
        @resources ||= Resources.new(context)
      end

      attr_reader :context

    end
  end
end
