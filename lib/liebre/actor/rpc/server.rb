require 'concurrent'

require 'liebre/actor/rpc/server/resources'
require 'liebre/actor/rpc/server/base'
require 'liebre/actor/rpc/server/extension'
require 'liebre/actor/rpc/server/callback'

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

        def __start__
          stack.start
        end

        def __stop__
          stack.stop
        end

        def __handle__ meta, payload
          stack.handle(meta, payload)
        end

        def __reply__ meta, response, opts = {}
          stack.reply(meta, response, opts)
        end

        def __failed__ meta, error
          stack.failed(meta, error)
        end

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
end
