module Liebre
  class Runner
    class Starter

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

      attr_reader :connection, :config

    end
  end
end