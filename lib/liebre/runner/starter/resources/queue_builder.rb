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
            q = channel.queue(queue_name, queue_opts)
            routing_keys.each do |key|
              q.bind(exchange, bind_opts.merge(:routing_key => key))
            end
            q
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
          
          def routing_keys
            bind_opts[:routing_key] ||= queue_name
            bind_opts[:routing_key] = [*bind_opts[:routing_key]]
            bind_opts.delete :routing_key
          end

          def bind_opts
            @bind_opts ||= Liebre::Common::Utils.symbolize_keys config.fetch("bind", {})
          end

          attr_reader :channel, :config
          
        end
      end
    end
  end
end