module Liebre
  class Runner
    class Consumers

      def initialize connection_manager
        @connection_manager = connection_manager
        @threads = []
      end
    
      def consumer_names
        consumers.keys
      end

      def start_all
        consumer_names.each do |name|
          start(name)
        end
      end
      
      def stop_all
        threads.each do |starter| 
          starter.stop
        end
      end

      def start name
        params = consumers.fetch(name)
        num_threads = params.fetch("num_threads", 1)
        num_threads.times do
          starter = Starter.new(connection_manager, params)
          starter.start
          threads << starter
        end
      end

      private

      def consumers
        Liebre.config.consumers
      end

      attr_reader :connection_manager, :threads

    end
  end
end
