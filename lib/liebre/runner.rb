module Liebre
  class Runner

    RETRY_INTERVAL = 5

    def initialize config: Liebre.config
      @config = config
    end

    def run
      setup_signals
      engine.start
      sleep
    rescue => e
      sleep(RETRY_INTERVAL)
      retry
    end

  private

    def setup_signals
      Signal.trap("TERM") { engine.stop; exit }
      Signal.trap("USR1") { engine.stop; exit }
    end

    def engine
      @engine ||= Engine.new(config)
    end

    attr_reader :config

  end
end
