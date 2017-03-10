require 'liebre/actor/publisher/extension/on_publication'

module Liebre
  module Actor
    class Publisher
      module Extension

        def initialize _chan, _context
        end

        def start
        end

        def on_publication payload, opts
          publication.continue(payload, opts)
        end

        def after_publish _payload, _opts
        end

        def after_cancel _payload, _opts
        end

        def stop
        end

      private

        def publication
          OnPublication
        end

      end
    end
  end
end
