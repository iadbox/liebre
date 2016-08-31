require "yaml"
require "bunny"

module Liebre
  class Config

    CONFIG_PATH = File.expand_path("config/liebre.yml")
    CONNECTION_PATH = File.expand_path("config/rabbitmq.yml")
    DEFAULT_LOGGER = Logger.new STDOUT
    DEFAULT_RPC_TIMEOUT = 5
    
    class << self
      attr_accessor :env
      attr_writer :config_path, :connection_path, :logger
      
      def config_path
        @config_path || CONFIG_PATH
      end
      
      def connection_path
        @connection_path || CONNECTION_PATH
      end
      
      def logger
        @logger || DEFAULT_LOGGER
      end
      
    end
    
    def consumers
      config.fetch 'consumers', {}
    end
    
    def publishers
      config.fetch 'publishers', {}
    end
    
    def rpc_request_timeout
      config.fetch 'rpc_request_timeout', DEFAULT_RPC_TIMEOUT
    end

    private

    def config
      @config ||= YAML.load_file self.class.config_path
    end

  end
end
