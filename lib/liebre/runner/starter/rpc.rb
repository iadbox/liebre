module Liebre
  class Runner
    class Starter
      class RPC < Consumer

        def call
          queue.subscribe(:manual_ack => false) do |_info, meta, payload|
            consumer = klass.new(payload, meta, callback(meta))
            consumer.call
          end
        end
        
        private

        def callback meta
          opts = {
            :routing_key    => meta.reply_to,
            :correlation_id => meta.correlation_id 
          }

          lambda { |response| exchange.publish(response, opts) }
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