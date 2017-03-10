require 'concurrent'

require 'liebre/actor/consumer/context'
require 'liebre/actor/consumer/handler'
require 'liebre/actor/consumer/callback'
require 'liebre/actor/consumer/extension'
require 'liebre/actor/consumer/stack'

module Liebre
  module Actor
    class Consumer
      include Concurrent::Async

      OPTS = {:block => false, :manual_ack => true}

      def initialize chan, spec, handler_class, pool, extension_classes = []
        super()

        @chan              = chan
        @spec              = spec
        @handler_class     = handler_class
        @pool              = pool
        @extension_classes = extension_classes
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def consume(info, meta, payload) async.__consume__(info, meta, payload); end

      def ack(info, opts = {})    async.__callback__(:ack,    info, opts); end
      def nack(info, opts = {})   async.__callback__(:nack,   info, opts); end
      def reject(info, opts = {}) async.__callback__(:reject, info, opts); end

      def fail(info, error) async.__fail__(info, error); end

      def __start__() stack.start; end
      def __stop__()  stack.stop;  end

      def __consume__(info, meta, payload) stack.consume(info, meta, payload); end
      def __callback__(action, info, opts) stack.callback(action, info, opts); end
      def __fail__(info, error)            stack.fail(info, error);            end

    private

      def queue
        context.queue
      end

      def stack
        @stack ||= Stack.new(self, extension_classes, context, handler)
      end

      def handler
        Handler.new(handler_class, pool)
      end

      def context
        Context.new(chan, spec)
      end

      attr_reader :chan, :spec, :handler_class, :pool, :extension_classes

    end
  end
end
