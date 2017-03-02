module Liebre
  class Connections

    def initialize config
      @config = config
    end

    def start
      all.each { |_name, conn| conn.start }
    end

    def stop
      all.each { |_name, conn| conn.stop }
    end

    def fetch name
      all.fetch(name)
    end

    def all
      @all ||= conn_configs.reduce({}) do |all, (name, opts)|
        connection = adapter.connection(opts)

        all.merge!(name => connection)
      end
    end

  private

    def conn_configs
      config.connections
    end

    def adapter
      config.adapter
    end

    attr_reader :config

  end
end
