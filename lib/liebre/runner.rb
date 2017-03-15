module Liebre
  class Runner

    RETRY_INTERVAL = 5

    def initialize engine: Liebre.engine
      @engine = engine
    end

    def run only: nil
      setup_signals
      engine.start(only: only)
      sleep
    rescue => e
      sleep(RETRY_INTERVAL)
      retry
    end

  private

    def setup_signals
      Signal.trap("TERM") { do_shutdown; exit }
      Signal.trap("USR1") { do_shutdown; exit }
    end

    def do_stop
      Thread.new { engine.stop }.join
    end

    attr_reader :engine

  end
end
