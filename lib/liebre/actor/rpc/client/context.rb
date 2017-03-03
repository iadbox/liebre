require 'concurrent'

module Liebre
  module Actor
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
              name = queue_config.fetch("name")
              opts = queue_config.fetch("opts")

              chan.queue(name, opts)
            end
          end

          def request_exchange
            @request_exchange ||= begin
              name = exchange_config.fetch("name")
              type = exchange_config.fetch("type")
              opts = exchange_config.fetch("opts")

              chan.exchange(name, type, opts)
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

          def exchange_config
            spec.fetch("exchange")
          end

          def queue_config
            spec.fetch("queue")
          end

          attr_reader :chan, :spec, :tasks

        end
      end
    end
  end
end
