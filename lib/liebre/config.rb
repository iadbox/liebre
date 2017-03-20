module Liebre
  class Config

    attr_accessor :adapter, :connections, :actors
    attr_writer :logger

    def logger
      @logger || null_logger
    end

  private

    def null_logger
      @null_logger ||= Logger.new(nil)
    end

  end
end
