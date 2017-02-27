require 'liebre/consumer/context'
require 'liebre/consumer/callback'

module Liebre
  class Consumer
    include Concurrent::Async

    OPTS = {:block => false, :manual_ack => true}

    def initialize chan, spec, handler_class, pool
      super()

      @chan          = chan
      @spec          = spec
      @handler_class = handler_class
      @pool          = pool
    end

    def start() async.__start__(); end
    def stop()  async.__stop__();  end

    def ack(info, opts = {})    async.__ack__(info, opts);    end
    def nack(info, opts = {})   async.__nack__(info, opts);   end
    def reject(info, opts = {}) async.__reject__(info, opts); end

    def __start__
      queue.subscribe(OPTS) do |info, meta, payload|
        callback = Callback.new(self, info)

        pool.post { handle(payload, meta, callback) }
      end
    end

    def __ack__ info, opts = {}
      queue.ack(info, opts)
    end

    def __nack__ info, opts = {}
      queue.nack(info, opts)
    end

    def __reject__ info, opts = {}
      queue.reject(info, opts)
    end

    def __stop__
      queue.unsubscribe
    end

  private

    def handle payload, meta, callback
      handler = handler_class.new(payload, meta, callback)
      handler.call
    rescue => e
      # TODO: Log error
      callback.reject()
    end

    def queue
      @queue ||= begin
        context = Context.new(chan, spec)
        context.queue
      end
    end

    attr_reader :chan, :spec, :handler_class, :pool

  end
end
