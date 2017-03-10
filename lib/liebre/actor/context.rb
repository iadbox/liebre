require "liebre/actor/context/declare"
require "liebre/actor/context/handler"
require "liebre/actor/context/stack_builder"

module Liebre
  module Actor
    class Context

      attr_reader :chan, :name, :opts

      def initialize chan, name, opts
        @chan = chan
        @name = name
        @opts = opts
      end

      def spec
        opts.fetch(:resources, {})
      end

      def declare
        @declare ||= Declare.new(chan)
      end

      def handler
        @handler ||= Handler.new(opts)
      end

      def build_stack resources, base
        builder = StackBuilder.new(self, opts, resources, base)
        builder.call
      end

    end
  end
end
