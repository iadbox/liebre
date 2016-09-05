require 'spec_helper'

RSpec.describe "Integration" do
  
  class MyConsumer
    
    def initialize payload, meta
      @payload = payload
      @meta = meta
    end
    
  end
  
  class MyRPC
    
    def initialize payload, meta, callback
      @payload = payload
      @meta = meta
      @callback = callback
    end
    
    def call
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
  
  let(:consumer) { double 'consumer' }
  
  it do
    
    main_thread = Thread.new do
      server = Liebre::Runner.new
      server.start
    end
    
    publisher = Liebre::Publisher.new("some_publisher")
    
    allow(MyConsumer).to receive(:new).with("hello", anything).and_return consumer
    
    #the consumer returns first :ack, then :reject and the message gets requed, then :error, and the message turns dead-lettered
    expect(consumer).to receive(:call).and_return :ack, :reject, :error
    
    publisher.enqueue "hello", :routing_key => "consumer_queue" #:ack
    publisher.enqueue "hello", :routing_key => "consumer_queue" #:reject then :error
    
    
    
    rpc_publisher = Liebre::Publisher.new("rpc_publisher")
    
    param = "return this string"
    
    result = rpc_publisher.rpc param, :routing_key => "rpc_queue"
    
    expect(result).to eq param
    
    sleep 0.1
  end
  
end