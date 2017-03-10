require "liebre/actor/context/declare"

module Liebre
  module Actor
    class Context

      attr_reader :chan, :name, :opts

      def initialize chan, name, opts
        @chan = chan
        @name = name
        @opts = opts
      end

      def declare
        @declare ||= Declare.new(chan)
      end

    end
  end
end
