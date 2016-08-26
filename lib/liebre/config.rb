require "yaml"
require "bunny"

module Liebre
  class Config

    CONFIG_PATH = File.expand_path("config/liebre.yml")
    CONNECTION_PATH = File.expand_path("config/rabbitmq.yml")
    
    class << self
      attr_accessor :env
      attr_writer :config_path, :connection_path
      
      def config_path
        @config_path || CONFIG_PATH
      end
      
      def connection_path
        @connection_path || CONNECTION_PATH
      end
    end
    
    def consumers
      config.fetch 'consumers', {}
    end
    
    def publishers
      config.fetch 'publishers', {}
    end

    private

    def config
      @config ||= YAML.load_file self.class.config_path
    end

  end
end
