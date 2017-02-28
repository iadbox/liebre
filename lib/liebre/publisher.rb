require 'concurrent'

require 'liebre/publisher/context'

module Liebre
  class Publisher
    include Concurrent::Async

    def initialize chan, spec
      super()

      @chan = chan
      @spec = spec
    end

    def start() __start__(); end
    def stop()  __stop__(); end

    def __start__
      exchange
    end

    def __stop__
    end

    def publish payload, opts = {}
      async.__publish__(payload, opts)
    end

    def __publish__ payload, opts = {}
      exchange.publish(payload, opts)
    end

  private

    def exchange
      @exchange ||= begin
        context = Context.new(chan, spec)
        context.exchange
      end
    end

    attr_reader :chan, :spec

  end
end
