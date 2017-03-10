module Liebre
  class Engine
    class Repository

      def initialize
        @publishers  = {}
        @consumers   = {}
        @rpc_clients = {}
        @rpc_servers = {}
      end

      def insert type, name, resource
        case type
          when :publishers  then publishers[name]  = resource
          when :consumers   then consumers[name]   = resource
          when :rpc_clients then rpc_clients[name] = resource
          when :rpc_servers then rpc_servers[name] = resource
        end
      end

      def all
        publishers.values + consumers.values + rpc_clients.values + rpc_servers.values
      end

      def each &block
        all.each(&block)
      end

      def clear
        publishers.clear
        consumers.clear
        rpc_clients.clear
        rpc_servers.clear
      end

      def publisher name
        publishers.fetch(name)
      end

      def consumer name
        consumers.fetch(name)
      end

      def rpc_client name
        rpc_clients.fetch(name)
      end

      def rpc_server name
        rpc_servers.fetch(name)
      end

      attr_reader :publishers, :consumers, :rpc_clients, :rpc_servers

    end
  end
end
