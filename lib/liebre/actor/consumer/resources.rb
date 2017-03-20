require 'liebre/actor/consumer/resources/config'

module Liebre
  module Actor
    class Consumer
      class Resources

        def initialize context
          @context = context
        end

        def queue
          @queue ||= declare.queue(config.queue).tap do |queue|
            declare.bind(queue, exchange, config.bind)
          end
        end

        def exchange
          @exchange ||= declare.exchange(config.exchange)
        end

        def dead_queue
          @dead_queue ||= declare.queue(config.dead_queue).tap do |queue|
            declare.bind(queue, dead_exchange)
          end
        end

        def dead_exchange
          @dead_exchange ||= declare.exchange(config.dead_exchange)
        end

      private

        def declare
          context.declare
        end

        def config
          @config ||= Config.new(context.spec)
        end

        attr_reader :context

      end
    end
  end
end
