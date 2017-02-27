module Liebre
  module RPC
    class Server
      class Context

        def initialize chan, spec
          @chan = chan
          @spec = spec
        end

        def exchange
          chan.default_exchange
        end

        def request_queue
          name = spec.queue_name
          opts = spec.queue_opts

          chan.queue(name, opts).tap do |queue|
            queue.bind(request_exchange)
          end
        end

      private

        def request_exchange
          name = spec.exchange_name
          opts = spec.exchange_opts

          chan.exchange(name, opts)
        end

        attr_reader :chan, :spec

      end
    end
  end
end
