module Liebre
  module Adapter
    class Bunny
      class Chan
        include Interface::Chan

        attr_reader :channel

        def initialize channel
          @channel = channel
        end

        def exchange name, opts
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
