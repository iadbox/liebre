module Liebre
  class Runner
    class Starter
      class Consumer

        autoload :Handler,   "liebre/runner/starter/consumer/handler"

        def initialize connection, config
          @connection = connection
          @config = config
        end

        def start
          initialize_error_queue
          initialize_queue
        end
        
        def stop
          if @consumer
            @consumer.cancel
            channel.close
          end
        end

        private

        def initialize_queue
          @consumer = queue.subscribe(:manual_ack => true) do |info, meta, payload|
            response = :reject
            debug_string = ""
            elapsed_time = nil
            begin
              debug_string = "Liebre# Received message for #{klass.name}(#{queue.name}): #{payload} - #{meta}"
              start_at = Time.now
              consumer = klass.new(payload, meta)
              response = consumer.call
              elapsed_time = (Time.now - start_at).to_f * 1000
            rescue StandardError => e
              response = :error
              logger.error error_string(e, payload, meta)
            rescue Exception => e
              response = :error
              logger.error error_string(e, payload, meta)
              handler.respond response, info
              raise e
            ensure
              debug_string += "\nLiebre# Responding with #{response}"
              log_result debug_string, elapsed_time
              handler.respond response, info
            end
          end
        end
        
        def log_result debug_string, elapsed_time
          time_string = "\nLiebre# Elapsed time #{elapsed_time} ms"
          if logger.debug?
            logger.debug debug_string + time_string
          else
            logger.info "Liebre# Received message for #{klass.name}(#{queue.name})" + time_string
          end
        end
        
        def error_string error, payload, meta
          "Liebre# Error while processing #{klass.name}(#{queue.name}): #{payload} - #{meta}" + 
            error.inspect + error.backtrace.join("\n")
        end

        def initialize_error_queue
          Resources.new(connection, error_config).queue
        end

        def klass
          @klass ||= Kernel.const_get config.fetch("class_name")
        end

        def handler
          @handler ||= Handler.new(channel)
        end

        def channel
          resources.channel
        end

        def exchange
          resources.exchange
        end

        def queue
          resources.queue
        end

        def resources
          @resources ||= Resources.new(connection, parse_config)
        end

        def parse_config
          result = clone_hash config
          result['queue']['opts']['arguments'] ||= {}
          result['queue']['opts']['arguments']['x-dead-letter-exchange'] = result['exchange']['name'] + "-error"
          result
        end

        def error_config
          result = clone_hash config
          result['exchange']['name'] += "-error"
          result['queue']['name'] += "-error"
          result
        end

        def logger
          Liebre::Config.logger
        end

        def clone_hash hash
          Marshal.load(Marshal.dump(hash))
        end

        attr_reader :connection, :config

      end
    end
  end
end
