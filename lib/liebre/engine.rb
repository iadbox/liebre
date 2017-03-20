require "liebre/engine/state"
require "liebre/engine/builder"

require "liebre/engine/repository"

module Liebre
  class Engine

    def initialize config
      @config = config
    end

    def start only: nil
      bridge.start

      state.to_start(only: only) do |type, name, opts|
        actor = build(type, name, opts)
        actor.start

        repo.insert(type, name, actor)
      end
    end

    def clean only: nil
      bridge.start

      state.to_clean(only: only) do |type, name, opts|
        actor = build(type, name, opts)
        actor.clean
      end
    end

    def stop
      repo.each(&:stop)
      repo.clear
      bridge.stop
    end

    def repo
      @repo ||= Repository.new
    end

  private

    def build type, name, opts
      builder = Builder.new(bridge, type, name, opts, config)
      builder.call
    end

    def state
      @state ||= State.new(config.actors)
    end

    def bridge
      @bridge ||= Bridge.new(config)
    end

    attr_reader :config

  end
end
