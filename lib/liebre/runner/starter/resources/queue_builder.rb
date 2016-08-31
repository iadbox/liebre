module Liebre
  class Runner
    class Starter
      class Resources
        class QueueBuilder

          def initialize channel, config
            @channel = channel
            @config  = config
          end

          def queue
            channel.queue(queue_name, queue_opts).bind(exchange, bind_opts)
          end

          def exchange
            Liebre::Common::Utils.create_exchange channel, exchange_config
          end

          private

          def queue_name
            queue_config.fetch("name")
          end

          def queue_opts
            Liebre::Common::Utils.symbolize_keys queue_config.fetch("opts", {})
          end

          def exchange_config
            config.fetch("exchange")
          end

          def queue_config
            config.fetch("queue")
          end

          def bind_opts
            Liebre::Common::Utils.symbolize_keys config.fetch("bind", {})
          end

          attr_reader :channel, :config
          
        end
      end
    end
  end
end