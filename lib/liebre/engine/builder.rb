module Liebre
  class Engine
    class Builder

      CONTEXT = Actor::Context

      ACTORS = {
        :publishers  => Actor::Publisher,
        :consumers   => Actor::Consumer,
        :rpc_clients => Actor::RPC::Client,
        :rpc_servers => Actor::RPC::Server
      }

      def initialize bridge, type, name, opts, context: CONTEXT, actors: ACTORS
        @bridge = bridge
        @type   = type
        @name   = name
        @opts   = opts

        @context_class = context
        @actor_classes = actors
      end

      def call
        actor_class.new(context)
      end

    private

      def actor_class
        actor_classes.fetch(type)
      end

      def context
        context_class.new(chan, name, opts)
      end

      def chan
        bridge.open_channel(opts)
      end

      attr_reader :bridge, :type, :name, :opts,
                  :context_class, :actor_classes

    end
  end
end
