module Liebre
  class Starter
    class Resources
      class QueueBuilder

        def initialize chan, config
          @chan   = chan
          @config = config
        end

        def call
          chan.queue(queue_name, queue_opts).tap do |queue|
            queue.bind(exchange, bind_opts)
          end
        end

        private

        def exchange
          chan.exchange(exchange_name, exchange_opts)
        end

        def exchange_name
          exchange_config.fetch("name")
        end

        def exchange_opts
          type = exchange_config.fetch("type", :fanout)
          opts = exchange_config.fetch("opts", {})

          opts.merge("type" => type).symbolize_keys
        end

        def queue_name
          queue_config.fetch("name")
        end

        def queue_opts
          queue_config.fetch("opts", {}).symbolize_keys
        end

        def exchange_config
          config.fetch("exchange")
        end

        def queue_config
          config.fetch("queue")
        end

        def bind_opts
          config.fetch("bind", {}).symbolize_keys
        end

        attr_reader :chan, :config

      end
    end
  end
end
