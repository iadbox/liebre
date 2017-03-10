module Liebre
  class Engine
    class Parser

      def initialize config
        @config = config
      end

      def each
        config.each do |type, specs|
          specs.each do |name, opts|
            yield(type, name, opts)
          end
        end
      end

    private

      attr_reader :config

    end
  end
end
