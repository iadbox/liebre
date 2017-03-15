module Liebre
  module Actor
    module RPC
      class Client
        class Reporter

          def initialize context
            @context = context
          end

          def on_start
            yield
            logger.info("RPC client started: #{name}")
          rescue Exception => error
            logger.error("Error starting RPC client: #{name}\n#{error.message}\n#{error.backtrace}")
            raise error
          end

          def on_stop
            yield
            logger.info("RPC client stopped: #{name}")
          rescue Exception => error
            logger.error("Error stopping RPC client: #{name}\n#{error.message}\n#{error.backtrace}")
            raise error
          end

          def on_request
            yield
          rescue Exception => error
            logger.error("Error performing request: #{name}\n#{error.message}\n#{error.backtrace}")
            raise error
          end

          def on_reply
            yield
          rescue Exception => error
            logger.error("Error receiving request reply: #{name}\n#{error.message}\n#{error.backtrace}")
            raise error
          end

          def on_expire
            yield
          rescue Exception => error
            logger.error("Error expiring RPC client pending requests: #{name}\n#{error.message}\n#{error.backtrace}")
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
end
