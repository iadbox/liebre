require 'concurrent'

require 'liebre/actor/rpc/client/resources'
require 'liebre/actor/rpc/client/pending'
require 'liebre/actor/rpc/client/task'
require 'liebre/actor/rpc/client/core'
require 'liebre/actor/rpc/client/reporter'

module Liebre
  module Actor
    module RPC
      class Client
        include Concurrent::Async

        TIMEOUT = 5

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

        def __start__()
          reporter.on_start { core.start }
        end
        def __stop__()
          reporter.on_stop { core.stop }
        end

        def __request__(payload, opts, timeout)
          reporter.on_request { core.request(payload, opts, timeout) }
        end

        def __reply__(meta, response)
          reporter.on_reply { core.reply(meta, response) }
        end

        def __expire__()
          reporter.on_expire { core.expire }
        end

      private

        def core
          @core ||= Core.new(self, resources, context, pending, task)
        end

        def resources
          Resources.new(context)
        end

        def pending
          Pending.new
        end

        def task
          Task.new
        end

        def reporter
          @reporter ||= Reporter.new(context)
        end

        attr_reader :context

      end
    end
  end
end
