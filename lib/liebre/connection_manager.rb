require "yaml"
require "bunny"
require "singleton"

module Liebre
  class ConnectionManager

    include Singleton

    def initialize
      @path = Liebre::Config.connection_path
      @connections = {}
      @channels = {}
      @lock = Mutex.new
    end

    def start
      @lock.synchronize do
        initialize_connections
        connections.each do |connection_name, bunny|
          begin
            bunny.start
          rescue => e
            $logger.error("#{self.class.name}: Can't connect to #{connection_name} instance")
            $logger.error(e.message + "\n" + e.backtrace.join("\n"))
          end
        end
      end
    end

    def ensure_started
      all_open = !@connections.empty? and @connections.all? do |_, bunny|
        bunny.open?
      end
      restart unless all_open
    end

    def restart
      stop
      start
    end

    def get connection_name
      connections[connection_name.to_sym]
    end

    def channel_for connection_name, consumer_pool_size = 1
      @lock.synchronize do
        channels[connection_name] ||= begin
          get(connection_name).create_channel nil, consumer_pool_size
        end
      end
    end

    def stop
      @lock.synchronize do
        connections.each do |_, bunny|
          if bunny and bunny.open?
            bunny.close
          end
        end
        connections.clear
      end
    end

    private

    def initialize_connections
      config.each do |name, conf|
        @connections[name.to_sym] = connection_for(conf)
      end
    end

    def connection_for config
      Bunny.new(config)
    end

    def config
      result = YAML.load_file(path)
      Liebre.env ? result.fetch(Liebre.env) : result
    end

    attr_reader :path, :connections, :channels

  end
end
