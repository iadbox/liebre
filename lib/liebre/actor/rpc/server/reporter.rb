module Liebre
  module Actor
    module RPC
      class Server
        class Reporter

          def initialize context
            @context = context
          end

          def on_start
            yield
            logger.info("RPC server started: #{name}")
          rescue Exception => e
            logger.error("Error starting RPC server: #{name}\n#{error.message}\n#{error.backtrace}")
            raise e
          end

          def on_stop
            yield
            logger.info("RPC server stopped: #{name}")
          rescue Exception => e
            logger.error("Error stopping RPC server: #{name}\n#{error.message}\n#{error.backtrace}")
            raise e
          end

          def on_handle
            yield
          rescue Exception => e
            logger.error("Error handling request: #{name}\n#{error.message}\n#{error.backtrace}")
            raise e
          end

          def on_reply
            yield
          rescue Exception => e
            logger.error("Error replying request: #{name}\n#{error.message}\n#{error.backtrace}")
            raise e
          end

          def on_failed
            yield
          rescue Exception => e
            logger.error("Error handling RPC server handler failure: #{name}\n#{error.message}\n#{error.backtrace}")
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
end
