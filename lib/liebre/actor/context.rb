require "liebre/actor/context/handler"
require "liebre/actor/context/extensions"

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

          resources_class.new(chan, spec)
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

      attr_reader :resources_class, :base_class

    end
  end
end
