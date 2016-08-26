module Liebre
  class Starter
    autoload :Resources, "liebre/starter/resources"

    def initialize connection, config
      @connection = connection
      @config = config
    end

    def call
      queue.subscribe do |_info, meta, payload|
        options = is_rpc? ? {:callback => callback(meta)} : {}
        consumer = klass.new(payload, meta, options)
        consumer.call
      end
    end

    private

    def callback meta
      opts = {:routing_key    => meta.reply_to,
        :correlation_id => meta.correlation_id}

      -> (response) { exchange.publish(response, opts) }
    end

    def klass
      @klass ||= config.fetch("class_name").constantize
    end
    
    def is_rpc?
      config.fetch("rpc", false)
    end

    def exchange
      resources.exchange
    end

    def queue
      resources.queue
    end

    def resources
      @resources ||= Resources.new(connection, config)
    end

    attr_reader :connection, :config

  end
end
