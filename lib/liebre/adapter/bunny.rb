begin
  require "bunny"
rescue
  # bunny not present
end

require "liebre/adapter/bunny/conn"
require "liebre/adapter/bunny/chan"
require "liebre/adapter/bunny/exchange"
require "liebre/adapter/bunny/queue"

module Liebre
  module Adapter
    class Bunny
      include Interface

      def connection opts
        Conn.new(opts)
      end

    end
  end
end
