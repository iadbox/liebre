module Liebre
  module Actor
    module RPC
      class Server
        class Context

          def initialize chan, spec
            @chan = chan
            @spec = spec
          end

          def response_exchange
            @response_exchange ||= chan.default_exchange
          end

          def request_queue
            @request_queue ||= begin
              name = queue_config.fetch("name")
              opts = queue_config.fetch("opts")

              chan.queue(name, symbolize(opts)).tap do |queue|
                queue.bind(request_exchange)
              end
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

        private

          def queue_config
            spec.fetch("queue")
          end

          def exchange_config
            spec.fetch("exchange")
          end

          def symbolize opts
            opts.reduce({}) { |new, (key, value)| new.merge!(key.to_sym => value) }
          end

          attr_reader :chan, :spec

        end
      end
    end
  end
end
