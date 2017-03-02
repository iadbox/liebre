require "liebre/engine/starter"
require "liebre/engine/repository"

module Liebre
  class Engine

    def initialize config
      @config = config
    end

    def start
      bridge.start

      starter.start_all.map do |(type, name, actor)|
        repo.insert(type, name, actor)
      end
    end

    def repo
      @repo ||= Repository.new
    end

    def stop
      bridge.stop

      repo.clear
    end

  private

    def starter
      Starter.new(bridge, config.actors)
    end

    def bridge
      @bridge ||= Bridge.new(config)
    end

    attr_reader :config

  end
end
