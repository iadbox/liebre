require 'concurrent'

require 'liebre/actor/rpc/client/context'
require 'liebre/actor/rpc/client/pending'
require 'liebre/actor/rpc/client/extension'
require 'liebre/actor/rpc/client/stack'

module Liebre
  module Actor
    module RPC
      class Client
        include Concurrent::Async

        REQUEST_TIMEOUT = 5

        def initialize chan, spec, extension_classes = []
          super()

          @chan              = chan
          @spec              = spec
          @extension_classes = extension_classes
        end

        def start() async.__start__(); end
        def stop()  async.__stop__();  end

        def request payload, opts = {}, timeout = REQUEST_TIMEOUT
          call_ivar     = await.__request__(payload, opts, timeout)
          response_ivar = call_ivar.value

          response_ivar.value(timeout)
        end

        def reply(meta, payload) async.__reply__(meta, payload); end
        def expire()             async.__expire__();             end

        def __start__() stack.start; end
        def __stop__()  stack.stop; end

        def __request__(payload, opts, timeout) stack.request(payload, opts, timeout); end
        def __reply__(meta, response)           stack.reply(meta, response);           end

        def __expire__() stack.expire; end

      private

        def stack
          @stack ||= Stack.new(self, extension_classes, context)
        end

        def context
          Context.new(chan, spec)
        end

        attr_reader :chan, :spec, :extension_classes

      end
    end
  end
end
