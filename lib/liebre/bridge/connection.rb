require 'concurrent'

module Liebre
  class Bridge
    class Connection
      include Concurrent::Async

      def initialize adapter, opts
        super()

        @adapter = adapter
        @opts    = opts
      end

      def start() async.__start__; end
      def stop()  async.__stop__;  end

      def channel
        ivar = await.__channel__
        ivar.value
      end

      def __start__
        conn.start
      end

      def __channel__
        conn.open_channel
      end

      def __stop__
        conn.stop
      end

    private

      def conn
        @conn ||= adapter.connection(opts)
      end

      attr_reader :adapter, :opts

    end
  end
end
