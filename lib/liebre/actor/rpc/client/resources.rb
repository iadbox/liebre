require 'concurrent'
require 'securerandom'

module Liebre
  module Actor
    module RPC
      class Client
        class Resources

          DEFAULT_PREFIX = "rpc_responses"

          QUEUE_OPTS = {:auto_delete => true,
                        :exclusive   => true,
                        :durable     => false}

          attr_reader :declare, :spec

          def initialize declare, spec
            @declare = declare
            @spec    = spec

            @tasks = []
          end

          def response_queue
            @response_queue ||= begin
              prefix = queue_config.fetch("prefix", DEFAULT_PREFIX)
              suffix = SecureRandom.urlsafe_base64

              config = {"name" => "#{prefix}_#{suffix}",
                        "opts" => QUEUE_OPTS}

              declare.queue(config)
            end
          end

          def request_exchange
            @request_exchange ||= declare.exchange(exchange_config)
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
            spec.fetch("queue", {})
          end

          def bind_config
            spec.fetch("bind", {})
          end

          attr_reader :tasks

        end
      end
    end
  end
end
