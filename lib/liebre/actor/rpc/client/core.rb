module Liebre
  module Actor
    module RPC
      class Client
        class Core

          OPTS            = {:block => false, :manual_ack => false}
          EXPIRE_INTERVAL = 60

          def initialize client, resources, context, pending, task
            @client    = client
            @resources = resources
            @context   = context
            @pending   = pending
            @task      = task
          end

          def start
            response_queue.subscribe(OPTS) do |_info, meta, payload|
              client.reply(meta, payload)
            end
            request_exchange

            task.every(EXPIRE_INTERVAL) { client.expire }
          end

          def stop
            task.cancel_all
            chan.close
          end

          def request payload, opts, timeout
            pending.add(timeout) do |correlation_id|
              opts = opts.merge :reply_to       => response_queue.name,
                                :correlation_id => correlation_id

              request_exchange.publish(payload, opts)
              context.logger.info("request pending - correlation_id: #{correlation_id}")
            end
          end

          def reply meta, response
            context.logger.info("about to finish - correlation_id: #{meta.correlation_id}")
            request = pending.finish(meta.correlation_id, response)
            context.logger.info("finished - correlation_id: #{meta.correlation_id}; request: #{request}")
          end

          def expire
            pending.expire()
          end

          def clean
            request_exchange.delete
            response_queue.delete
          end

        private

          def response_queue
            resources.response_queue
          end

          def request_exchange
            resources.request_exchange
          end

          def chan
            context.chan
          end

          attr_reader :client, :resources, :context, :pending, :task

        end
      end
    end
  end
end
