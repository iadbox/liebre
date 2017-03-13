require 'concurrent'

require 'liebre/actor/publisher/resources'
require 'liebre/actor/publisher/base'
require 'liebre/actor/publisher/extension'

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

      def __start__() stack.start; end
      def __stop__()  stack.stop; end

      def __publish__(payload, opts = {}) stack.publish(payload, opts); end

    private

      def stack
        @stack ||= context.build_stack(resources, base)
      end

      def base
        Base.new(resources, context)
      end

      def resources
        @resources ||= Resources.new(context)
      end

      attr_reader :context

    end
  end
end
