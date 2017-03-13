require 'concurrent'

require 'liebre/actor/publisher/resources'
require 'liebre/actor/publisher/core'

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

      def __start__() core.start; end
      def __stop__()  core.stop;  end

      def __publish__(payload, opts) core.publish(payload, opts); end

    private

      def core
        @core ||= Core.new(resources, context)
      end

      def resources
        Resources.new(context)
      end

      attr_reader :context

    end
  end
end
