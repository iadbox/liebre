require 'concurrent'

require 'liebre/actor/consumer/resources'
require 'liebre/actor/consumer/callback'
require 'liebre/actor/consumer/core'
require 'liebre/actor/consumer/reporter'

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

      def clean() async.__clean__(); end

      def __start__
        reporter.on_start { core.start }
      end
      def __stop__
        reporter.on_stop { core.stop }
      end

      def __consume__ info, meta, payload
        reporter.on_consume { core.consume(info, meta, payload) }
      end

      def __ack__(info, opts)
        reporter.on_ack { core.ack(info, opts) }
      end
      def __nack__(info, opts)
        reporter.on_nack { core.nack(info, opts) }
      end
      def __reject__(info, opts)
        reporter.on_reject { core.reject(info, opts) }
      end

      def __failed__(info, error)
        reporter.on_failed(error) { core.failed(info, error) }
      end

      def __clean__
        reporter.on_clean { core.clean() }
      end

    private

      def core
        @core ||= Core.new(self, resources, context, Callback)
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
