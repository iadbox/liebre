module Liebre
  module Actor
    class Consumer
      class Resources
        class Config

          def initialize spec
            @spec = spec
          end

          def queue
            raw_queue.merge(:opts => dead_letter_opts)
          end

          def exchange
            raw_exchange
          end

          def bind
            spec.fetch(:bind, {})
          end

          def dead_queue
            {:name => error_name,
             :opts => raw_queue.fetch(:opts, {})}
          end

          def dead_exchange
            {:name => error_name,
             :type => "fanout",
             :opts => raw_exchange.fetch(:opts, {})}
          end

        private

          def dead_letter_opts
            raw_queue.fetch(:opts, {}).dup.tap do |opts|
              opts[:arguments] = opts.
                fetch(:arguments, {}).
                merge("x-dead-letter-exchange" => error_name)
            end
          end

          def error_name
            @error_name ||= begin
              raw_name = spec.fetch(:queue).fetch(:name)
              "#{raw_name}-error"
            end
          end

          def raw_exchange
            spec.fetch(:exchange)
          end

          def raw_queue
            spec.fetch(:queue)
          end

          attr_reader :spec

        end
      end
    end
  end
end
