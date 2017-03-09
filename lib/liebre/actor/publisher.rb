require 'concurrent'

require 'liebre/actor/publisher/context'
require 'liebre/actor/publisher/resources'
require 'liebre/actor/publisher/extension'
require 'liebre/actor/publisher/stack'


module Liebre
  module Actor
    class Publisher
      include Concurrent::Async

      def initialize chan, spec, extension_classes = []
        super()

        @chan              = chan
        @spec              = spec
        @extension_classes = extension_classes
      end

      def start() async.__start__(); end
      def stop()  async.__stop__();  end

      def publish(payload, opts = {}) async.__publish__(payload, opts); end

      def __start__() stack.start; end
      def __stop__()  stack.stop;  end

      def __publish__(payload, opts = {}) stack.publish(payload, opts); end

    private

      def stack
        @stack ||= Stack.new(extension_classes, context)
      end

      def context
        Context.new(chan, spec)
      end

      attr_reader :chan, :spec, :extension_classes

    end
  end
end
