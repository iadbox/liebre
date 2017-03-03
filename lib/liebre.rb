require "liebre/version"

require "liebre/adapter"
require "liebre/config"

require "liebre/bridge"
require "liebre/actor"
require "liebre/engine"

module Liebre

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
