require 'concurrent'
require 'securerandom'

require 'liebre/actor/rpc/client/stack/base'

require 'liebre/actor/rpc/client/stack/on_request'
require 'liebre/actor/rpc/client/stack/on_reply'

module Liebre
  module Actor
    module RPC
      class Client
        class Stack

          OPTS            = {:block => false, :manual_ack => false}
          EXPIRE_INTERVAL = 60

          def initialize client, extension_classes, context
            @client            = client
            @extension_classes = extension_classes
            @context           = context
          end

          def start
            context.response_queue.subscribe(OPTS) do |_info, meta, payload|
              client.reply(meta, payload)
            end
            context.request_exchange
            extensions.start

            context.recurrent_task(EXPIRE_INTERVAL) do
              client.expire
            end
          end

          def stop
            context.response_queue.unsubscribe
            context.cancel_tasks
            extensions.stop
            context.chan.close
          end

          def request payload, opts, timeout
            correlation_id = new_correlation_id()
            result         = extensions.on_request(correlation_id, payload, opts)

            if result.continue?
              do_request(correlation_id, result.payload, result.opts, timeout)
            else
              Concurrent::IVar.new(result.response)
            end
          end

          def reply meta, response
            correlation_id = meta.correlation_id
            result         = extensions.on_reply(correlation_id, response)

            pending.finish(correlation_id, result.response)
            extensions.after_reply(correlation_id, result.response)
          end

          def expire
            pending.expire
          end

        private

          def do_request correlation_id, payload, opts, timeout
            opts = opts.merge :reply_to       => context.response_queue.name,
                              :correlation_id => correlation_id
            context.request_exchange.publish(payload, opts)

            pending.add(correlation_id, timeout).tap do
              extensions.after_request(correlation_id, payload, opts)
            end
          end

          def extensions
            @extensions ||= begin
              Shared::Extensions.build(extension_classes, Base, context)
            end
          end

          def pending
            @pending ||= Pending.new
          end

          def new_correlation_id
            SecureRandom.urlsafe_base64
          end

          attr_reader :client, :extension_classes, :context

        end
      end
    end
  end
end
