module Liebre
  module Actor
    class Publisher
      class Reporter

        def initialize context
          @context = context
        end

        def on_start
          yield
          logger.info("Publisher started: #{name}")
        rescue Exception => e
          logger.error("Error starting publisher: #{name}\n#{error.message}\n#{error.backtrace}")
          raise e
        end

        def on_publish
          yield
        rescue Exception => e
          logger.error("Error publising: #{name}\n#{error.message}\n#{error.backtrace}")
          raise e
        end

        def on_stop
          yield
          logger.info("Publisher stopped: #{name}")
        rescue Exception => e
          logger.error("Error stopping publisher: #{name}\n#{error.message}\n#{error.backtrace}")
          raise e
        end

      private

        def name
          @name ||= context.name.inspect
        end

        def logger
          @logger ||= context.logger
        end

        attr_reader :context

      end
    end
  end
end
