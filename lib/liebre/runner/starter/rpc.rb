module Liebre
  class Runner
    class Starter
      class RPC < Consumer

        def start
          @consumer = queue.subscribe(:manual_ack => false) do |_info, meta, payload|
            begin
              logger.debug "Liebre: Received message for #{klass.name}: #{payload} - #{meta}"
              consumer = klass.new(payload, meta, callback(meta))
              consumer.call
            rescue => e
              logger.error e.inspect
              logger.error e.backtrace.join("\n")
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
            logger.debug "Liebre: Responding with #{response}"
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