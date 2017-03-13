module Liebre
  module Actor
    class Publisher
      class Core

        def initialize resources, context
          @resources = resources
          @context   = context
        end

        def start
          exchange
        end

        def stop
          chan.close
        end

        def publish payload, opts
          exchange.publish(payload, opts)
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
