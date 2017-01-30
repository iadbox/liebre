module Liebre
  class Runner
    class Starter
      
      autoload :Consumer,  'liebre/runner/starter/consumer'
      autoload :Resources, 'liebre/runner/starter/resources'
      autoload :RPC,       'liebre/runner/starter/rpc'

      def initialize connection_manager, config
        @connection_manager = connection_manager
        @config = config
      end

      def start
       @consumer = consumer_class.new(connection, config).start
      end
      
      def stop
        @consumer.cancel
      end

      private
      
      def consumer_class
        is_rpc? ? RPC : Consumer
      end
    
      def is_rpc?
        config.fetch("rpc", false)
      end
      
      def connection
        connection_manager.get connection_name
      end
      
      def connection_name
        config.fetch('connection_name', 'default').to_sym
      end

      attr_reader :connection_manager, :config

    end
  end
end