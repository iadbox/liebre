require 'concurrent'

require 'liebre/bridge/channel_builder'

module Liebre
  class Bridge
    NotStarted = Class.new(StandardError)

    def initialize config
      @config  = config
      @started = false
    end

    def started?
      @started
    end

    def start
      if not started?
        connections.each do |name, conn|
          conn.start
          logger.info("Connection started: #{name.inspect}")
        end

        self.started = true
      end
    end

    def open_channel opts
      if started?
        builder = ChannelBuilder.new(connections, opts)
        builder.call
      else
        raise NotStarted
      end
    end

    def stop
      if started?
        connections.each { |_name, conn| conn.stop }

        self.started = false
      end
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
    attr_writer :started

  end
end
