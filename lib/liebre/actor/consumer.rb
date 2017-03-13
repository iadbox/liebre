require 'concurrent'

require 'liebre/actor/consumer/resources'
require 'liebre/actor/consumer/base'
require 'liebre/actor/consumer/extension'
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

      def __start__() stack.start; end
      def __stop__()  stack.stop;  end

      def __consume__(info, meta, payload) stack.consume(info, meta, payload); end

      def __ack__(info, opts = {})    stack.callback(info, :ack, opts);    end
      def __nack__(info, opts = {})   stack.callback(info, :nack, opts);   end
      def __reject__(info, opts = {}) stack.callback(info, :reject, opts); end

      def __failed__(info, error) stack.failed(info, error); end

    private

      def stack
        @stack ||= context.build_stack(resources, base)
      end

      def base
        Base.new(self, resources, context, Callback)
      end

      def resources
        @resources ||= Resources.new(context)
      end

      attr_reader :context

    end
  end
end
