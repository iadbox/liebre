require 'liebre/actor/rpc/server/stack/base'

require 'liebre/actor/rpc/server/stack/on_request'
require 'liebre/actor/rpc/server/stack/on_reply'
require 'liebre/actor/rpc/server/stack/on_failure'

module Liebre
  module Actor
    module RPC
      class Server
        class Stack

          OPTS = {:block => false, :manual_ack => false}

          def initialize server, extension_classes, context, handler
            @server            = server
            @extension_classes = extension_classes
            @context           = context
            @handler           = handler
          end

          def start
            context.request_queue.subscribe(OPTS) do |info, meta, payload|
              server.handle(info, meta, payload)
            end
            context.response_exchange
            extensions.start
          end

          def stop
            context.request_queue.unsubscribe
            extensions.stop
            context.chan.close
          end

          def handle info, meta, payload
            callback = Callback.new(server, info, meta)
            tag      = info.delivery_tag
            result   = extensions.on_request(tag, payload, meta, callback)

            if result.continue?
              do_consume(result.payload, result.meta, result.callback)
            else
              do_cancel(tag, payload, meta, callback)
            end
          end

          def reply info, meta, response, opts
            tag    = info.delivery_tag
            result = extensions.on_reply(tag, response, opts)

            if result.continue?
              do_reply(meta, result.response, result.opts)
            end
          end

          def fail info, meta, error
            tag    = info.delivery_tag
            result = extensions.on_failure(tag, error)

            if result.respond?
              do_reply(meta, result.response, result.opts)
            end
          end

        private

          def do_consume payload, meta, callback
            handler.call(payload, meta, callback)
          end

          def do_cancel tag, payload, meta, callback
            extensions.after_cancel(tag, payload, meta, callback)
          end

          def do_reply meta, response, opts
            opts = opts.merge :routing_key    => meta.reply_to,
                              :correlation_id => meta.correlation_id

            context.response_exchange.publish(response, opts)
          end

          def extensions
            @extensions ||= begin
              Shared::Extensions.build(extension_classes, Base, context)
            end
          end

          attr_reader :server, :extension_classes, :context, :handler

        end
      end
    end
  end
end
