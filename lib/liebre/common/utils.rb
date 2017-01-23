module Liebre
  module Common
    module Utils
      
      @@mutex = Mutex.new
      
      def self.mutex_sync
        @@mutex.synchronize do
          yield
        end
      end
      
      def self.create_exchange channel, config
        exchange_name = config.fetch "name"
        
        type = config.fetch("type")
        opts = config.fetch("opts", {})
        exchange_opts = symbolize_keys(opts.merge("type" => type))
        
        mutex_sync { channel.exchange exchange_name, exchange_opts }
      end
      
      def self.symbolize_keys hash
        result = {}
        hash.each do |k, v|
          result[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v
        end
        result
      end
    end

  end
end