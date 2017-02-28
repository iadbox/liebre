module Liebre
  module Actor
    class Consumer
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def queue
          name = spec.queue_name
          opts = spec.queue_opts

          chan.queue(name, opts).tap do |queue|
            queue.bind(exchange)
          end
        end

      private

        def exchange
          name = spec.exchange_name
          opts = spec.exchange_opts

          chan.exchange(name, opts)
        end

        attr_reader :chan, :spec

      end
    end
  end
end
