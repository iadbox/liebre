require 'concurrent'

require 'liebre/actor/rpc/client/resources'
require 'liebre/actor/rpc/client/base'
require 'liebre/actor/rpc/client/extension'
require 'liebre/actor/rpc/client/task'
require 'liebre/actor/rpc/client/pending'

module Liebre
  module Actor
    module RPC
      class Client
        include Concurrent::Async

        TIMEOUT         = 5
        OPTS            = {:block => false, :manual_ack => false}
        EXPIRE_INTERVAL = 60

        def initialize context
          super()

          @context = context
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def request payload, opts = {}, timeout = TIMEOUT
          call_ivar     = await.__request__(payload, opts, timeout)
          response_ivar = call_ivar.value

          response_ivar.value(timeout)
        end
        def reply(meta, response) async.__reply__(meta, response); end

        def expire() async.__expire__(); end

        def __start__
          stack.start
        end

        def __stop__
          stack.stop
        end

        def __request__ payload, opts = {}, timeout = TIMEOUT
          stack.request(payload, opts, timeout)
        end

        def __reply__ meta, response
          stack.reply(meta, response)
        end

        def __expire__
          stack.expire
        end

      private

        def stack
          @stack ||= context.build_stack(resources, base)
        end

        def base
          Base.new(self, resources, context, pending, task)
        end

        def resources
          @resources ||= Resources.new(context)
        end

        def pending
          @pending ||= Pending.new
        end

        def task
          @task ||= Task.new
        end

        attr_reader :context

      end
    end
  end
end
