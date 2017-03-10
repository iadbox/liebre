require 'liebre/actor/consumer/extension/on_consume'
require 'liebre/actor/consumer/extension/on_callback'

module Liebre
  module Actor
    class Consumer
      module Extension

        def initialize _chan, _context
        end

        def start
        end

        def on_consume message, meta, callback
          consume.continue(message, meta, callback)
        end

        def on_callback _message, _meta, action, opts
          callback.do(action, opts)
        end

        def stop
        end

      private

        def consume
          OnConsume
        end

        def callback
          OnCallback
        end

      end
    end
  end
end
