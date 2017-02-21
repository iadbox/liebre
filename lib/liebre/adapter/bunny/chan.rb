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

        def close
          channel.close
        end

      end
    end
  end
end
