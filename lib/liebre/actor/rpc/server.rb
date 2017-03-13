require 'concurrent'

require 'liebre/actor/rpc/server/resources'
require 'liebre/actor/rpc/server/callback'
require 'liebre/actor/rpc/server/core'

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

        def __start__() core.start; end
        def __stop__()  core.stop;  end

        def __handle__(meta, payload) core.handle(meta, payload); end

        def __reply__(meta, response, opts) core.reply(meta, response, opts); end

        def __failed__(meta, error) core.failed(meta, error); end

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
end
