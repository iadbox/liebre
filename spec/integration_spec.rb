require 'spec_helper'

RSpec.describe "Integration" do
  
  class MyConsumer
    
    def initialize payload, meta, options
      @payload = payload
      @meta = meta
    end
    
    def call
      puts @payload
      puts @meta.inspect
    end
    
  end
  
  class MyRPC
    
    def initialize payload, meta, options
      @payload = payload
      @meta = meta
      @callback = options[:callback]
    end
    
    def call
      puts @payload
      puts @meta.inspect
      @callback.call(@payload)
    end
    
  end
  
  let :config_path do
    File.expand_path("../config/liebre.yml" ,__FILE__)
  end
    
  let :connection_path do
    File.expand_path("../config/rabbitmq.yml" ,__FILE__)
  end
  
  before do
    Liebre::Config.config_path     = config_path
    Liebre::Config.connection_path = connection_path
  end
  
  it "subscribes each consumer to its queue" do
    
    main_thread = Thread.new do
      server = Liebre::Runner.new
      puts "starting"
      server.start
      puts "sleeping"
    end.join
    5.times do
      puts main_thread.status
      sleep 0.1
    end
    
  end
  
end