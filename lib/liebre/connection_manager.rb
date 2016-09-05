require "yaml"
require "bunny"

module Liebre
  class ConnectionManager

    def initialize path = Liebre::Config.connection_path
      @path = path
      @connections = {}
    end

    def start
      initialize_connections
      connections.each do |_, bunny|
        bunny.start
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

    def stop
      connections.each do |_, bunny|
        if bunny and bunny.open?
          bunny.close
        end
      end
      connections.clear
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

    attr_reader :path, :connections

  end
end
