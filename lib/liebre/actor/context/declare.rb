module Liebre
  module Actor
    class Context
      class Declare

        def initialize chan
          @chan = chan
        end

        def default_exchange
          chan.default_exchange
        end

        def exchange config
          name = config.fetch(:name)
          type = config.fetch(:type)
          opts = config.fetch(:opts, {})

          chan.exchange(name, type, opts)
        end

        def queue config
          name = config.fetch(:name)
          opts = config.fetch(:opts, {})

          chan.queue(name, opts)
        end

        def bind queue, exchange, config = {}
          all_opts = [config].flatten

          all_opts.each do |opts|
            queue.bind(exchange, opts)
          end
        end

      private

        attr_reader :chan

      end
    end
  end
end
