module Liebre
  class Publisher
    
    def initialize publisher_name
      @publisher_name = publisher_name
    end
    
    def enqueue message, options = {}
      with_connection do
        exchange = exchange_for default_channel
        logger.debug "Liebre: Publishing '#{message}' with '#{options}' to exchange: #{exchange.name}"
        exchange.publish message, options
      end
    end
    
    def enqueue_and_wait message, options = {}
      result = nil
      with_rpc_channel do |channel|
        correlation_id = options[:correlation_id] ||= generate_uuid
        reply_queue = reply_queue channel, correlation_id
        options[:reply_to] = reply_queue.name
        reply_queue.subscribe(:block => false) do |delivery_info, meta, payload|
          if meta[:correlation_id] == correlation_id
            result = payload
            logger.debug "Liebre: Received response '#{result}'"
            channel.consumers[delivery_info.consumer_tag].cancel
          end
        end
        exchange = exchange_for channel
        logger.debug "Liebre: Publishing '#{message}' with '#{options}' to exchange: #{exchange.name}"
        exchange.publish message, options
        begin
          Timeout.timeout(Liebre.config.rpc_request_timeout) do
            sleep 0.01 while result.nil?
          end
        rescue Timeout::Error
          #do nothing
        end
      end
      result
    end
    
    alias_method :rpc, :enqueue_and_wait
    
    private
    
    def with_connection
      connection_manager.ensure_started
      begin
        yield
      rescue Bunny::Exception => e
        logger.warn("#{self.class.name}: #{e.class} found restarting connection - #{e.message}")
        connection_manager.restart
        retry
      end
    end
    
    def with_rpc_channel
      with_connection do
        channel = connection_manager.get(connection_name).create_channel
        yield(channel)
        channel.close
      end
    end
    
    def default_channel
      @default_channel ||= connection_manager.channel_for(connection_name)
    end
    
    def reply_queue channel, correlation_id
      queue_name = "#{publisher_name}_callback_#{correlation_id}"
      channel.queue queue_name, :exclusive => true, :auto_delete => true
    end
    
    def exchange_for channel 
      Liebre::Common::Utils.create_exchange channel, exchange_config
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
      
    def connection_name
      config.fetch('connection_name', 'default').to_sym
    end

    def connection_manager
      @connection_manager ||= ConnectionManager.instance
    end
    
    def generate_uuid
      SecureRandom.uuid
    end
        
    def logger
      Liebre::Config.logger
    end
    
    attr_reader :publisher_name

  end
end
