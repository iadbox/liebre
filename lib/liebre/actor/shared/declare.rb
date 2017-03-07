module Liebre
  module Actor
    module Shared
      class Declare

        def initialize chan
          @chan = chan
        end

        def exchange config
          name = config.fetch("name")
          type = config.fetch("type")
          opts = config.fetch("opts", {})

          chan.exchange(name, type, symbolize(opts))
        end

        def queue config
          name = config.fetch("name")
          opts = config.fetch("opts", {})

          chan.queue(name, symbolize(opts))
        end

        def bind queue, exchange, config
          all_opts = [config].flatten

          all_opts.each do |opts|
            queue.bind(exchange, symbolize(opts))
          end
        end

      private

        def symbolize opts
          opts.each_with_object({}) do |(key, value), new|
            new[key.to_sym] = value
          end
        end

        attr_reader :chan

      end
    end
  end
end
