require "liebre/engine/parser"
require "liebre/engine/builder"

require "liebre/engine/repository"

module Liebre
  class Engine

    def initialize config
      @config = config
    end

    def start only: nil
      bridge.start

      parser.each(only) do |type, name, opts|
        actor = build(type, name, opts)
        config.logger.info("about to start: #{type} - #{name}")
        actor.start

        repo.insert(type, name, actor)
      end
    end

    def stop
      repo.each(&:stop)
      bridge.stop

      repo.clear
    end

    def repo
      @repo ||= Repository.new
    end

  private

    def build type, name, opts
      builder = Builder.new(bridge, type, name, opts, config)
      builder.call
    end

    def parser
      Parser.new(config.actors)
    end

    def bridge
      @bridge ||= Bridge.new(config)
    end

    attr_reader :config

  end
end
