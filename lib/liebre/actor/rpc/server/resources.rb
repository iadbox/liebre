module Liebre
  module Actor
    module RPC
      class Server
        class Resources

          attr_reader :declare, :spec

          def initialize declare, spec
            @declare = declare
            @spec    = spec
          end

          def response_exchange
            @response_exchange ||= declare.default_exchange
          end

          def request_queue
            @request_queue ||= declare.queue(queue_config).tap do |queue|
              declare.bind(queue, request_exchange, bind_config)
            end
          end

          def request_exchange
            @request_exchange ||= declare.exchange(exchange_config)
          end

        private

          def queue_config
            spec.fetch("queue")
          end

          def exchange_config
            spec.fetch("exchange")
          end

          def bind_config
            spec.fetch("bind", {})
          end

        end
      end
    end
  end
end
