require 'concurrent'

require 'liebre/actor/consumer/resources'
require 'liebre/actor/consumer/callback'
require 'liebre/actor/consumer/core'

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

      def __start__() core.start; end
      def __stop__()  core.stop;  end

      def __consume__(info, meta, payload) core.consume(info, meta, payload); end

      def __ack__(info, opts) core.ack(info, opts); end
      def __nack__(info, opts) core.nack(info, opts); end
      def __reject__(info, opts) core.reject(info, opts); end

      def __failed__(info, error) core.failed(info, error); end

    private

      def core
        @core ||= Core.new(self, resources, context, Callback)
      end

      def resources
        Resources.new(context)
      end

      attr_reader :context

    end
  end
end
