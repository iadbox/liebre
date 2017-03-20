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
        rescue Exception => error
          logger.error("Error starting publisher: #{name}\n#{error.message}\n#{error.backtrace}")
          raise error
        end

        def on_publish
          yield
        rescue Exception => error
          logger.error("Error publising: #{name}\n#{error.message}\n#{error.backtrace}")
          raise error
        end

        def on_stop
          yield
          logger.info("Publisher stopped: #{name}")
        rescue Exception => error
          logger.error("Error stopping publisher: #{name}\n#{error.message}\n#{error.backtrace}")
          raise error
        end

        def on_clean
          yield
        rescue Exception => error
          logger.error("Error cleaning publisher: #{name}\n#{error.message}\n#{error.backtrace}")
          raise error
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
