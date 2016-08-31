module Liebre
  class Runner
    class Starter
      class Consumer
        class Handler

          def initialize channel
            @channel = channel
          end
          
          def respond action, meta
            send(action, meta.delivery_tag)
          end

          private
          
          def ack delivery_tag
            channel.acknowledge delivery_tag
          end
          
          def reject delivery_tag
            channel.reject delivery_tag, true
          end
          
          def error delivery_tag
            channel.reject delivery_tag, false            
          end

          attr_reader :channel
        
        end
      end
    end
  end
end