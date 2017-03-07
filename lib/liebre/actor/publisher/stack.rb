require 'liebre/actor/publisher/stack/base'
require 'liebre/actor/publisher/stack/on_publication'

module Liebre
  module Actor
    class Publisher
      class Stack

        def initialize extension_classes, context
          @extension_classes = extension_classes
          @context           = context
        end

        def start
          context.exchange
          extensions.start
        end

        def stop
          extensions.stop
          context.chan.close
        end

        def publish payload, opts
          result = extensions.on_publication(payload, opts)

          if result.continue?
            do_publish(result.payload, result.opts)
          else
            do_cancel(payload, opts)
          end
        end

      private

        def do_publish payload, opts
          context.exchange.publish(payload, opts)

          extensions.after_publish(payload, opts)
        end

        def do_cancel payload, opts
          extensions.after_cancel(payload, opts)
        end

        def extensions
          @extensions ||= begin
            Shared::Extensions.build(extension_classes, Base, context)
          end
        end

        attr_reader :extension_classes, :context

      end
    end
  end
end
