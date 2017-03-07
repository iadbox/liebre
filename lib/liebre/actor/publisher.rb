require 'concurrent'

require 'liebre/actor/publisher/context'

module Liebre
  module Actor
    class Publisher
      include Concurrent::Async

      def initialize chan, spec
        super()

        @chan = chan
        @spec = spec
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def publish payload, opts = {}
        async.__publish__(payload, opts)
      end

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
        context.exchange
      end

      def context
        @context ||= Context.new(chan, spec)
      end

      attr_reader :chan, :spec

    end
  end
end
