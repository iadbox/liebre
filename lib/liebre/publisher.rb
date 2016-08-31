module Liebre
  class Publisher
    
    def initialize publisher_name
      @publisher_name = publisher_name
    end
    
    def enqueue message, options = {}
      with_connection do
        exchange.publish message, options
      end
    end
    
    def enqueue_and_wait message, options = {}
      with_connection do
        begin
          correlation_id = options[:correlation_id] ||= generate_uuid
          reply_queue = queue_for(correlation_id)
          options[:reply_to] = reply_queue.name
          exchange.publish message, options
          result = nil
          Timeout::timeout(Liebre.config.rpc_request_timeout) do
            reply_queue.subscribe(:block => true) do |delivery_info, properties, payload|
              if properties[:correlation_id] == correlation_id
                result = payload
                channel.consumers[delivery_info.consumer_tag].cancel
              end
            end
          end
        rescue Timeout::Error
          #do nothing
        ensure
          reply_queue.delete
          return result
        end
      end
    end
    
    alias_method :rpc, :enqueue_and_wait
    
    private
    
    def with_connection
      conn_manager.start
      yield 
      conn_manager.stop      
    end
    
    def queue_for correlation_id
      queue_name = "#{publisher_name}_callback_#{correlation_id}"
      channel.queue queue_name, :exclusive => true
    end
    
    def exchange
      Liebre::Common::Utils.create_exchange channel, exchange_config
    end
    
    def channel
      @channel ||= conn_manager.get.create_channel
    end
    
    def publishers
      Liebre.config.publishers
    end

    def exchange_config
      config.fetch("exchange")
    end
    
    def config
      publishers.fetch publisher_name
    end

    def conn_manager
      @conn_manager ||= ConnectionManager.new
    end
    
    def generate_uuid
      SecureRandom.uuid
    end
    
    attr_reader :publisher_name

  end
end
