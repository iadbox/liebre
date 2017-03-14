require "liebre/actor/context/declare"
require "liebre/actor/context/handler"

module Liebre
  module Actor
    class Context

      attr_reader :chan, :name, :opts

      def initialize chan, name, opts, config
        @chan = chan
        @name = name
        @opts = opts

        @config = config
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

      def logger
        config.logger
      end

    private

      attr_reader :config

    end
  end
end
