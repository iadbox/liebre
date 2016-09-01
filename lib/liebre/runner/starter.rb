module Liebre
  class Runner
    class Starter
      
      autoload :Consumer,  'liebre/runner/starter/consumer'
      autoload :Resources, 'liebre/runner/starter/resources'
      autoload :RPC,       'liebre/runner/starter/rpc'

      def initialize connection, config
        @connection = connection
        @config = config
      end

      def call
        consumer_class.new(connection, config).call
      end

      private
      
      def consumer_class
        is_rpc? ? RPC : Consumer
      end
    
      def is_rpc?
        config.fetch("rpc", false)
      end

      attr_reader :connection, :config

    end
  end
end