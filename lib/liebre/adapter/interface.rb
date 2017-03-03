require "liebre/adapter/interface/conn"
require "liebre/adapter/interface/chan"
require "liebre/adapter/interface/exchange"
require "liebre/adapter/interface/queue"

module Liebre
  module Adapter
    module Interface

      def self.included base
        base.extend(ClassMethods)
      end

      def connection _config
        raise NotImplementedError, "All adapters must implement connection(config) to build a new connection"
      end

      module ClassMethods
        def connection config
          new.connection(config)
        end
      end

    end
  end
end
