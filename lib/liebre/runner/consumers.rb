module Liebre
  class Runner
    class Consumers

      def initialize connection_manager
        @connection_manager = connection_manager
      end
    
      def consumer_names
        consumers.keys
      end

      def start_all
        consumer_names.each { |name| start(name) }
      end

      def start name
        params = consumers.fetch(name)
        num_threads = params.fetch("num_threads", 1)
        num_threads.times do
          starter = Starter.new(connection_manager, params)
          starter.call
        end
      end

      private

      def consumers
        Liebre.config.consumers
      end

      attr_reader :connection_manager

    end
  end
end
