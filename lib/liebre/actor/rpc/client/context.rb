require 'concurrent'
require 'securerandom'

module Liebre
  module Actor
    module RPC
      class Client
        class Context

          DEFAULT_PREFIX = "rpc_responses"

          QUEUE_OPTS = {:auto_delete => true,
                        :exclusive   => true,
                        :durable     => false}

          def initialize chan, spec
            @chan = chan
            @spec = spec

            @tasks = []
          end

          def response_queue
            @response_queue ||= begin
              prefix = queue_config.fetch("prefix", DEFAULT_PREFIX)
              suffix = SecureRandom.urlsafe_base64

              chan.queue("#{prefix}_#{suffix}", QUEUE_OPTS)
            end
          end

          def request_exchange
            @request_exchange ||= begin
              name = exchange_config.fetch("name")
              type = exchange_config.fetch("type")
              opts = exchange_config.fetch("opts")

              chan.exchange(name, type, symbolize(opts))
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
            spec.fetch("queue", {})
          end

          def symbolize opts
            opts.reduce({}) { |new, (key, value)| new.merge!(key.to_sym => value) }
          end

          attr_reader :chan, :spec, :tasks

        end
      end
    end
  end
end
