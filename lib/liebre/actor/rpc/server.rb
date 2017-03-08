require 'concurrent'

require 'liebre/actor/rpc/server/context'
require 'liebre/actor/rpc/server/handler'
require 'liebre/actor/rpc/server/callback'
require 'liebre/actor/rpc/server/extension'
require 'liebre/actor/rpc/server/stack'

module Liebre
  module Actor
    module RPC
      class Server
        include Concurrent::Async

        def initialize chan, spec, handler_class, pool, extension_classes = []
          super()

          @chan              = chan
          @spec              = spec
          @handler_class     = handler_class
          @pool              = pool
          @extension_classes = extension_classes
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def handle(info, meta, payload) async.__handle__(info, meta, payload); end

        def reply(info, meta, response, opts = {}) async.__reply__(info, meta, response, opts); end
        def fail(info, meta, error)                async.__fail__(info, meta, error);           end

        def __start__() stack.start; end
        def __stop__()  stack.stop;  end

        def __handle__(info, meta, payload) stack.handle(info, meta, payload); end

        def __reply__(info, meta, response, opts = {}) stack.reply(info, meta, response, opts); end
        def __fail__(info, meta, error)                stack.fail(info, meta, error);           end

      private

        def stack
          @stack ||= Stack.new(self, extension_classes, context, handler)
        end

        def context
          Context.new(chan, spec)
        end

        def handler
          Handler.new(handler_class, pool)
        end

        attr_reader :chan, :spec, :handler_class, :pool, :extension_classes

      end
    end
  end
end
