require 'spec_helper'

RSpec.describe Liebre::Runner::Starter::Consumer do

  let(:connection) { double 'connection' }
  
  let(:class_name) { "MyConsumer" }
  let(:pool_size)  { 4 }

  let :config do
    {
      "class_name" => class_name,
      "pool_size"  => pool_size,
      "rpc" => false,
      "exchange" => {
        "name" => "test_exchange",
        "type" => "direct",
        "opts" => {
          "durable" => true
        }
      },
      "queue" => {
        "name" => "test_queue",
        "opts" => {
          "durable" => true
        }        
      }
    }
  end

  let :error_config do
    {
      "class_name" => class_name,
      "pool_size"  => pool_size,
      "rpc" => false,
      "exchange" => {
        "name" => "test_exchange-error",
        "type" => "direct",
        "opts" => {
          "durable" => true
        }
      },
      "queue" => {
        "name" => "test_queue-error",
        "opts" => {
          "durable" => true
        }        
      }
    }
  end

  let :parsed_config do
    {
      "class_name" => class_name,
      "pool_size"  => pool_size,
      "rpc" => false,
      "exchange" => {
        "name" => "test_exchange",
        "type" => "direct",
        "opts" => {
          "durable" => true
        }
      },
      "queue" => {
        "name" => "test_queue",
        "opts" => {
          "durable" => true,
          "arguments" => {
            'x-dead-letter-exchange' => "test_exchange-error"
          }
        }        
      }
    }
  end

  let(:exchange)    { double 'exchange' }
  let(:queue)       { double 'queue', :name => "queue" }
  let(:error_queue) { double 'error_queue' }
  let(:channel)     { double 'channel' }
  let(:consumer)    { double 'consumer' }
  let(:payload)     { "the_payload" }

  subject { described_class.new(connection, config) }

  let :resources do
    double 'resources', :exchange => exchange, :queue => queue, :channel => channel
  end
  
  let :error_resources do
    double 'resources', :queue => error_queue
  end
    
  let(:class_name) { "MyConsumer" }

  let(:consumer_class)    { double 'consumer_class', :name => 'consumer_class' }
  let(:consumer_instance) { double 'consumer_instance' }
    
  let :meta do
    double 'meta'
  end
  
  let(:handler) { double 'handler' }
  
  let(:deliver_info) { double 'deliver_info' }
  let(:ack) { :ack }

  before do
    expect(Liebre::Runner::Starter::Resources).to receive(:new).
      with(connection, error_config).and_return(error_resources)
    
    expect(Liebre::Runner::Starter::Resources).to receive(:new).
      with(connection, parsed_config).and_return(resources)

    stub_const(class_name, consumer_class)
    
    expect(described_class::Handler).to receive(:new).
      with(channel).and_return handler
  end

  it 'creates error queue and creates and subscribes to standard queue' do
    
    expect(queue).to receive :subscribe do |&block|
      block.call(deliver_info, meta, payload)
      consumer
    end

    expect(consumer_class).to receive :new do |given_payload, given_meta|
      expect(given_payload).to eq payload
      expect(given_meta   ).to eq meta

      consumer_instance
    end

    expect(consumer_instance).to receive(:call).and_return ack
    
    expect(handler).to receive(:respond).with ack, deliver_info

    subject.start
    
    expect(consumer).to receive(:cancel)
    expect(channel).to receive(:close)
    subject.stop
  end
    
end