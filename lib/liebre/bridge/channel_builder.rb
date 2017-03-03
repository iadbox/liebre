module Liebre
  class Bridge
    class ChannelBuilder

      DEFAULT_PREFETCH = 10

      def initialize connections, opts
        @connections = connections
        @opts        = opts
      end

      def call
        connection.open_channel.tap do |channel|
          channel.set_prefetch(prefetch_count)
        end
      end

    private

      def connection
        connections.fetch(conn_name)
      end

      def conn_name
        opts.fetch("connection")
      end

      def prefetch_count
        opts.fetch("prefetch_count", DEFAULT_PREFETCH)
      end

      attr_reader :connections, :opts

    end
  end
end
