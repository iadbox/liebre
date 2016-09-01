module Liebre
  class Runner
    class Starter
      class Consumer
        
        autoload :Handler,   "liebre/runner/starter/consumer/handler"

        def initialize connection, config
          @connection = connection
          @config = config
        end

        def call
          initialize_error_queue
          initialize_queue
        end
        
        private
        
        def initialize_queue
          queue.subscribe(:manual_ack => true) do |info, meta, payload|
            begin
              consumer = klass.new(payload, meta)
              response = consumer.call
              handler.respond response, info
            rescue => e
              logger.error e.inspect
              logger.error e.backtrace.first(5).join("\n")
              handler.respond :error, info
            end
          end
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
          result['queue']['opts']['exclusive'] = true
          result
        end
        
        def clone_hash hash
          Marshal.load(Marshal.dump(hash))
        end

        attr_reader :connection, :config
        
      end
    end
  end
end