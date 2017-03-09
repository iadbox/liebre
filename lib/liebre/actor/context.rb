require "liebre/actor/context/handler"
require "liebre/actor/context/extensions"
require "liebre/actor/context/declare"

module Liebre
  module Actor
    class Context

      attr_reader :chan, :name, :opts

      def initialize chan, name, opts, resources_class, base_class
        @chan            = chan
        @name            = name
        @opts            = opts
        @resources_class = resources_class
        @base_class      = base_class
      end

      def resources
        @resources ||= begin
          spec = opts.fetch("resources", {})

          resources_class.new(declare, spec)
        end
      end

      def handler
        @handler ||= Handler.new(opts)
      end

      def extensions
        @extensions ||= begin
          builder = Extensions.new(self, base_class)
          builder.call
        end
      end

    private

      def declare
        @declare ||= Declare.new(chan)
      end

      attr_reader :resources_class, :base_class

    end
  end
end
