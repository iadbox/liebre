require 'concurrent'

require 'liebre/actor/rpc/client/resources'
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
          response_queue.subscribe(OPTS) do |_info, meta, payload|
            reply(meta, payload)
          end
          request_exchange

          task.every(EXPIRE_INTERVAL) { expire }
        end

        def __stop__
          response_queue.unsubscribe
          task.cancel_all
          chan.close
        end

        def __request__ payload, opts = {}, timeout = TIMEOUT
          pending.add(timeout) do |correlation_id|
            opts = opts.merge :reply_to       => response_queue.name,
                              :correlation_id => correlation_id

            request_exchange.publish(payload, opts)
          end
        end

        def __reply__ meta, response
          pending.finish(meta.correlation_id, response)
        end

        def __expire__
          pending.expire
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

        def resources
          @resources ||= Resources.new(context)
        end

        def task
          @task ||= Task.new
        end

        def pending
          @pending ||= Pending.new
        end

        attr_reader :context

      end
    end
  end
end
