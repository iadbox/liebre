require "liebre/version"

require "liebre/adapter"
require "liebre/config"

require "liebre/bridge"
require "liebre/actor"
require "liebre/engine"

require "liebre/runner"

module Liebre

  def self.start only: nil
    runner = Runner.new(engine: Liebre.engine)
    runner.run(only: only)
  end

  def self.config
    @config ||= Config.new
  end

  def self.engine
    @engine ||= Engine.new(config)
  end

  def self.repo
    engine.repo
  end

  def self.configure
    yield(config)
  end

end
