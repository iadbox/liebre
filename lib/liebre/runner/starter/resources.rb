module Liebre
  class Starter
    class Resources
      autoload :QueueBuilder, "liebre/starter/resources/queue_builder"

      def initialize connection, config
        @connection   = connection
        @config = config
      end

      def exchange
        @exchange ||= channel.default_exchange
      end

      def queue
        @queue ||= begin
          builder = QueueBuilder.new(channel, config)
          builder.call
        end
      end

      private

      def channel
        @channel ||= connection.create_channel(nil, pool_size)
      end

      def pool_size
        config.fetch("pool_size", 1)
      end

      attr_reader :connection, :config

    end
  end
end