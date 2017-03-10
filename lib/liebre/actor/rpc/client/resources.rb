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

          def initialize context
            @context = context
          end

          def response_queue
            @response_queue ||= declare.queue(:name => queue_name, :opts => QUEUE_OPTS)
          end

          def request_exchange
            @request_exchange ||= declare.exchange(exchange_config)
          end

        private

          def queue_name
            prefix = queue_config.fetch(:prefix, DEFAULT_PREFIX)
            suffix = SecureRandom.urlsafe_base64

            "#{prefix}_#{suffix}"
          end

          def exchange_config
            spec.fetch(:exchange)
          end

          def queue_config
            spec.fetch(:queue, {})
          end

          def bind_config
            spec.fetch(:bind, {})
          end

          def spec
            context.spec
          end

          def declare
            context.declare
          end

          attr_reader :context

        end
      end
    end
  end
end
