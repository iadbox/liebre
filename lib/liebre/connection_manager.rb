require "yaml"
require "bunny"

module Liebre
  class ConnectionManager

    CONFIG_PATH = File.expand_path("config/rabbitmq.yml")

    def initialize path = Liebre::Config.connection_path
      @path = path
    end

    def start
      bunny.start
    end

    def restart
      stop
      start
    end

    def get
      bunny
    end

    def stop
      if bunny and bunny.open?
        bunny.close
      end

      @bunny = nil
    end

    private

    def bunny
      @bunny ||= Bunny.new(config)
    end

    def config
      result = YAML.load_file(path)
      Liebre.env ? result.fetch(Liebre.env) : result
    end

    attr_reader :path

  end
end
