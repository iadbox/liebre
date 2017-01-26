module Liebre
  class Runner
    
    autoload :Consumers, 'liebre/runner/consumers'
    autoload :Starter,   'liebre/runner/starter'
    
    RETRY_INTERVAL = 5

    def initialize retry_interval = RETRY_INTERVAL
      @retry_interval = retry_interval
    end

    def start
      setup_shutdown
      connection_manager.restart
      start_consumers
      sleep
    rescue StandardError => e
      log_and_wait(e)
      retry
    end

  private

    def setup_shutdown
      Signal.trap("TERM") { do_shutdown; exit }
    end

    def do_shutdown
      Thread.start do
        logger.info("Liebre: Closing AMQP connection...")
        consumers.stop
        connection_manager.stop
        logger.info("Liebre: AMQP connection closed")
      end.join
    end

    def start_consumers
      consumers.start_all
    end

    def log_and_wait e
      logger.warn(e)
      sleep(retry_interval)
      logger.warn("Liebre: Retrying connection")
    end

    def logger
      Liebre.logger
    end
    
    def consumers
      @consumers ||= Consumers.new(connection_manager)
    end

    def connection_manager
      @connection_manager ||= ConnectionManager.instance
    end

    attr_reader :retry_interval

  end
end
