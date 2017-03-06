module Liebre
  module Adapter
    class Bunny
      class Chan
        include Interface::Chan

        attr_reader :channel

        def initialize channel
          @channel = channel
        end

        def default_exchange
          Exchange.new(channel.default_exchange)
        end

        def exchange name, type, opts
          opts = opts.merge(:type => type)

          Exchange.new(channel.exchange(name, opts))
        end

        def queue name, opts
          Queue.new(channel.queue(name, opts))
        end

        def set_prefetch count
          channel.basic_qos(count, false)
        end

        def close
          channel.close
        end

      end
    end
  end
end
