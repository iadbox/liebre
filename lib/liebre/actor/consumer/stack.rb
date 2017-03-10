require 'liebre/actor/consumer/stack/base'

require 'liebre/actor/consumer/stack/on_consume'
require 'liebre/actor/consumer/stack/on_callback'

module Liebre
  module Actor
    class Consumer
      class Stack

        OPTS = {:block => false, :manual_ack => true}

        def initialize consumer, extension_classes, context, handler
          @consumer          = consumer
          @extension_classes = extension_classes
          @context           = context
          @handler           = handler
        end

        def start
          context.queue.subscribe(OPTS) do |info, meta, payload|
            consumer.consume(info, meta, payload)
          end
          extensions.start
        end

        def stop
          context.queue.unsubscribe
          extensions.stop
          context.chan.close
        end

        def consume info, meta, payload
          callback = Callback.new(consumer, info)
          tag      = info.delivery_tag
          result   = extensions.on_consume(tag, payload, meta, callback)

          if result.continue?
            do_consume(result.payload, result.meta, result.callback)
          else
            do_cancel(tag, payload, meta, callback)
          end
        end

        def callback action, info, opts
          tag    = info.delivery_tag
          result = extensions.on_callback(tag, action, opts)

          case result.action
            when :ack    then context.queue.ack(info, result.opts)
            when :nack   then context.queue.nack(info, result.opts)
            when :reject then context.queue.reject(info, result.opts)
          end
          extensions.after_callback(tag, result.action, result.opts)
        end

      private

        def do_consume payload, meta, callback
          handler.call(payload, meta, callback)
        end

        def do_cancel tag, payload, meta, callback
          extensions.after_cancel(tag, payload, meta, callback)
        end

        def extensions
          @extensions ||= begin
            Shared::Extensions.build(extension_classes, Base, context)
          end
        end

        attr_reader :consumer, :extension_classes, :context, :handler

      end
    end
  end
end
