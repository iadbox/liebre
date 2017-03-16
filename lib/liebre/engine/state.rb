module Liebre
  class Engine
    class State

      def initialize config
        @config  = config
        @started = Hash.new { |hash, key| hash[key] = {} }
      end

      def to_start only: nil
        all do |type, name, opts|
          if has_to_start?(type, name, only)
            yield(type, name, opts)
            set_started(type, name)
          end
        end
      end

      def to_clean only: nil
        all do |type, name, opts|
          yield(type, name, opts) if match?(type, only)
        end
      end

    private

      def has_to_start? type, name, only
        started[type][name].nil? and match?(type, only)
      end

      def match? type, only
        only.nil? or only.include?(type)
      end

      def set_started type, name
        started[type][name] = true
      end

      def all
        config.each do |type, specs|
          specs.each { |name, opts| yield(type, name, opts) }
        end
      end

      attr_reader :config, :started

    end
  end
end
