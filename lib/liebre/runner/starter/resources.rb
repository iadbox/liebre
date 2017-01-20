module Liebre
  class Runner
    class Starter
      class Resources
        autoload :QueueBuilder, "liebre/runner/starter/resources/queue_builder"

        def initialize connection, config
          @connection   = connection
          @config = config
        end

        def exchange
          @exchange ||= queue_builder.exchange
        end

        def queue
          @queue ||= queue_builder.queue
        end

        def channel
          @channel ||= connection.create_channel(nil, pool_size).tap do |channel|
            channel.prefetch(prefetch_count)
          end
        end

        private

        def queue_builder
          @queue_bilder ||= QueueBuilder.new(channel, config)
        end

        def prefetch_count
          config.fetch("prefetch_count", 10)
        end

        def pool_size
          config.fetch("pool_size", 1)
        end

        attr_reader :connection, :config

      end
    end
  end
end
