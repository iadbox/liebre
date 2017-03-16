require 'concurrent'

require 'liebre/actor/publisher/resources'
require 'liebre/actor/publisher/core'
require 'liebre/actor/publisher/reporter'

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

      def clean() async.__clean__(); end

      def __start__
        reporter.on_start { core.start }
      end
      def __stop__
        reporter.on_stop { core.stop }
      end

      def __publish__ payload, opts
        reporter.on_publish { core.publish(payload, opts) }
      end

      def __clean__
        reporter.on_clean { core.clean() }
      end

    private

      def core
        @core ||= Core.new(resources, context)
      end

      def resources
        Resources.new(context)
      end

      def reporter
        @reporter ||= Reporter.new(context)
      end

      attr_reader :context

    end
  end
end
