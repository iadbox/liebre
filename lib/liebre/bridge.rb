require 'concurrent'

require 'liebre/bridge/channel_builder'

module Liebre
  class Bridge

    def initialize config
      @config = config
    end

    def start
      connections.each do |name, conn|
        conn.start
        logger.info("Connection started: #{name.inspect}")
      end
    end

    def open_channel opts
      builder = ChannelBuilder.new(connections, opts)
      builder.call
    end

    def stop
      connections.each { |_name, conn| conn.stop }
    end

  private

    def connections
      @connections ||= conn_configs.reduce({}) do |all, (name, opts)|
        connection = adapter.connection(opts)

        all.merge!(name => connection)
      end
    end

    def logger
      config.logger
    end

    def adapter
      config.adapter
    end

    def conn_configs
      config.connections
    end

    attr_reader :config

  end
end
