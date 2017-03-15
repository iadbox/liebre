module Liebre
  class Engine
    class Parser

      def initialize config
        @config = config
      end

      def each only
        config.each do |type, specs|
          specs.each do |name, opts|
            yield(type, name, opts) if match?(type, only)
          end
        end
      end

    private

      def match? type, only
        only.nil? or only.include?(type)
      end

      attr_reader :config

    end
  end
end
