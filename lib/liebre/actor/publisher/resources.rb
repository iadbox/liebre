module Liebre
  module Actor
    class Publisher
      class Resources

        def initialize context
          @context = context
        end

        def exchange
          @exchange ||= declare.exchange(exchange_config)
        end

      private

        def exchange_config
          spec.fetch(:exchange)
        end

        def spec
          context.spec
        end

        def declare
          context.declare
        end

        attr_reader :context

      end
    end
  end
end
