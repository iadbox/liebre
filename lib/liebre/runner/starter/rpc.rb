module Liebre
  class Runner
    class Starter
      class RPC < Consumer

        def start
          @consumer = queue.subscribe(:manual_ack => false) do |_info, meta, payload|
            begin
              debug_string = "Liebre# Received message for #{klass.name}(#{queue.name}): #{payload} - #{meta}"
              start_at = Time.now
              consumer = klass.new(payload, meta, callback(meta))
              consumer.call
              elapsed_time = (Time.now - start_at).to_f * 1000
              log_result debug_string, elapsed_time
            rescue StandardError => e
              response = :error
              logger.error error_string(payload, meta)
            rescue Exception => e
              response = :error
              logger.error error_string(payload, meta)
              handler.respond response, info
              raise e
            end
          end
        end
        
        private

        def callback meta
          opts = {
            :routing_key    => meta.reply_to,
            :correlation_id => meta.correlation_id,
            :headers        => meta.headers
          }

          lambda do |response| 
            logger.debug "Liebre# Responding with #{response}"
            exchange.publish(response, opts)
          end
        end

        def exchange
          channel.default_exchange
        end
        
        def parse_config
          config
        end
        
      end
    end
  end
end