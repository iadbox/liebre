require 'concurrent'

module Liebre
  module RPC
    class Client
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec

          @tasks = []
        end

        def response_queue
          @response_queue ||= begin
            name = spec.queue_name
            opts = spec.queue_opts

            chan.queue(name, opts)
          end
        end

        def request_exchange
          @request_exchange ||= begin
            name = spec.exchange_name
            opts = spec.exchange_opts

            chan.exchange(name, opts)
          end
        end

        def recurrent_task interval, &block
          task = Concurrent::TimerTask.new(execution_interval: interval, &block)
          tasks << task

          task.execute
        end

        def cancel_tasks
          tasks.each(&:shutdown)
          tasks.clear
        end

      private

        attr_reader :chan, :spec, :tasks

      end
    end
  end
end
