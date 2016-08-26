require "liebre/version"

module Liebre
  
  autoload :Config,            'liebre/config'
  autoload :ConnectionManager, 'liebre/connection_manager'
  autoload :Runner,            'liebre/runner'
  
  def self.config
    @config ||= Config.new
  end
  
  def self.env
    Config.env
  end
  
end