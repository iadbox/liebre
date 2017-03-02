require "liebre/engine/starter/shared"

require "liebre/engine/starter/publisher"
require "liebre/engine/starter/consumer"
require "liebre/engine/starter/rpc/client"
require "liebre/engine/starter/rpc/server"

module Liebre
  class Engine
    class Starter

      STARTERS = {
        "publishers"  => Publisher,
        "consumers"   => Consumer,
        "rpc_clients" => RPC::Client,
        "rpc_servers" => RPC::Server
      }

      def initialize bridge, specs
        @bridge = bridge
        @specs  = specs
      end

      def start_all
        specs.flat_map do |type, type_specs|
          type_specs.map do |name, opts|
            resource = build(type, opts)

            [type, name, resource]
          end
        end
      end

    private

      def build type, opts
        starter_class = STARTERS.fetch(type)

        starter = starter_class.new(bridge, opts)
        starter.call
      end

      attr_reader :bridge, :specs

    end
  end
end
