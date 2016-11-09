require 'spec_helper'

RSpec.describe Liebre::Runner::Starter::RPC do

  let(:connection) { double 'connection' }
  
  let(:class_name) { "MyRPC" }
  let(:pool_size)  { 4 }

  let :config do
    {
      "class_name" => class_name,
      "pool_size"  => pool_size,
      "rpc" => true,
      "exchange" => {
        "name" => "test_exchange",
        "type" => "direct",
        "opts" => {
          "durable" => false
        }
      },
      "queue" => {
        "name" => "test_queue",
        "opts" => {
          "durable" => false
        }        
      }
    }
  end

  let(:exchange) { double 'exchange' }
  let(:queue)    { double 'queue' }
  let(:channel)  { double 'channel', :default_exchange => exchange }
  let(:payload)  { "the_payload" }
  let(:response) { "the_response" }

  subject { described_class.new(connection, config) }

  let :resources do
    double 'resources', :exchange => exchange, :queue => queue, :channel => channel
  end
    
  let(:class_name) { "MyConsumer" }

  let(:rpc_class)    { double 'rpc_class', :name => 'rpc_class' }
  let(:rpc_instance) { double 'rpc_instance' }
    
  let(:reply_to)       { "queue_to_reply_to" }
  let(:correlation_id) { 123 }
  let(:headers)        { {} }
  let :meta do
    double 'meta', 
      :reply_to       => reply_to,
      :correlation_id => correlation_id,
      :headers        => headers
  end
  
  let :opts do
    {:routing_key => reply_to, :correlation_id => correlation_id, :headers => headers}
  end
  
  let(:handler) { double 'handler' }
  
  let(:deliver_info) { double 'deliver_info' }

  before do
    allow(Liebre::Runner::Starter::Resources).to receive(:new).
      with(connection, config).and_return(resources)

    stub_const(class_name, rpc_class)
  end

  it 'creates error queue and creates and subscribes to standard queue' do
    
    expect(exchange).to receive(:publish).with(response, opts)
      
    expect(queue).to receive :subscribe do |&block|
      block.call(deliver_info, meta, payload)
    end

    expect(rpc_class).to receive :new do |given_payload, given_meta, callback|
      expect(given_payload).to eq payload
      expect(given_meta   ).to eq meta
      callback.call(response)

      rpc_instance
    end

    expect(rpc_instance).to receive(:call)

    subject.call
  end
    
end