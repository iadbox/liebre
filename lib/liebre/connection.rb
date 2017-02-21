module Liebre
  class Connection

    attr_reader :adapter, :opts

    def initialize adapter, opts = {}
      @adapter = adapter
      @opts    = opts
    end

    def start
      conn.start
    end

    def open_channel
      conn.open_channel
    end

    def stop
      conn.stop
    end

  private

    def conn
      @conn ||= adapter.connection(opts)
    end

  end
end
