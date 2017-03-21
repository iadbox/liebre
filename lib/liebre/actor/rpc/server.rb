require 'concurrent'

require 'liebre/actor/rpc/server/resources'
require 'liebre/actor/rpc/server/callback'
require 'liebre/actor/rpc/server/core'
require 'liebre/actor/rpc/server/reporter'

module Liebre
  module Actor
    module RPC
      class Server
        include Concurrent::Async

        OPTS = {:block => false, :manual_ack => false}

        def initialize context
          super()

          @context = context
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def handle(meta, payload) async.__handle__(meta, payload); end

        def reply(meta, response, opts = {}) async.__reply__(meta, response, opts); end
        def failed(meta, error)              async.__failed__(meta, error);         end

        def clean() async.__clean__(); end

        def __start__()
          reporter.on_start { core.start }
        end
        def __stop__()
          reporter.on_stop { core.stop }
        end

        def __handle__(meta, payload)
          reporter.on_handle { core.handle(meta, payload) }
        end

        def __reply__(meta, response, opts)
          reporter.on_reply { core.reply(meta, response, opts) }
        end

        def __failed__(meta, error)
          reporter.on_failed(error) { core.failed(meta, error) }
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
end
