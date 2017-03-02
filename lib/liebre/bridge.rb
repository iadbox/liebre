require 'concurrent'

require 'liebre/bridge/connection'
require 'liebre/bridge/channel_builder'

module Liebre
  class Bridge

    def initialize config
      @config = config
    end

    def start
      connections.each { |_name, conn| conn.start }
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
        connection = Connection.new(adapter, opts)

        all.merge!(name => connection)
      end
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
