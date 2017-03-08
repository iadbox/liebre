module Liebre
  module Actor
    module RPC
      class Server
        class Context

          attr_reader :chan, :spec

          def initialize chan, spec
            @chan = chan
            @spec = spec
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

          def declare
            @declare ||= Shared::Declare.new(chan)
          end

        end
      end
    end
  end
end
