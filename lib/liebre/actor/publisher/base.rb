require 'concurrent'

require 'liebre/actor/publisher/resources'

module Liebre
  module Actor
    class Publisher
      class Base

        def initialize resources, context
          @resources = resources
          @context   = context
        end

        def start
          exchange
        end

        def publish payload, opts
          exchange.publish(payload, opts)
        end

        def stop
          chan.stop
        end

      private

        def exchange
          resources.exchange
        end

        def chan
          context.chan
        end

        attr_reader :resources, :context

      end
    end
  end
end
