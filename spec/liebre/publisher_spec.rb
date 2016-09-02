require 'spec_helper'

RSpec.describe Liebre::Publisher do

  let :exchange_config do
    { 
      'name' => "test_exchange",
      'type' => "direct",
      'opts' => {
        'durable' => false
      }
    }
  end
  
  let :publishers_config do
    { 
      'test_publisher' => {
        'exchange' =>
          exchange_config 
      }
    }
  end
  
  let(:channel)            { double 'channel' }
  let(:bunny_connection)   { double 'bunny_conection',    :create_channel => channel }
  let(:connection_manager) { double 'connection_manager', :get => bunny_connection }
  let(:exchange)           { double 'exchange' }
  
  before do
    allow_any_instance_of(Liebre::Config).to receive(:publishers).and_return publishers_config
    allow_any_instance_of(Liebre::Config).to receive(:rpc_request_timeout).and_return 10
    
    expect(Liebre::ConnectionManager).to receive(:new).and_return connection_manager
    expect(connection_manager).to receive(:start)
    expect(connection_manager).to receive(:stop)
    
    expect(Liebre::Common::Utils).to receive(:create_exchange).
      with(channel, exchange_config).and_return exchange
    
  end
  
  subject { described_class.new 'test_publisher' }
  
  describe "#enqueue" do
    it do
      message = "abc"
      expect(exchange).to receive(:publish).with message, {}
    
      subject.enqueue message
    end
  end
  
  describe "#enqueue_and_wait" do
    
    let(:correlation_id)   { "correlation_id" }
    let(:reply_queue_name) { "test_publisher_callback_#{correlation_id}" }
    let(:reply_queue)      { double "reply_queue", :name => reply_queue_name }
    let(:delivery_info)    { double "delivery_info", :consumer_tag => "tag"}
    let(:consumer)         { double 'consumer' }
    let(:consumers)        { {"tag" => consumer} }
    
    before do
      expect(channel).to receive(:queue).with(reply_queue_name, :exclusive => true).
        and_return reply_queue
    end
    
    it do
      message = "question"
      answer = "answer"
      expect(exchange).to receive(:publish).with message, 
        {:correlation_id => correlation_id, :reply_to => reply_queue_name}
      
      expect(reply_queue).to receive(:subscribe).with(:block => true) do |&block|
        expect(channel).to receive(:consumers).and_return consumers
        expect(consumer).to receive(:cancel)
        
        block.call(delivery_info, {:correlation_id => correlation_id}, answer)
      end
      
      expect(reply_queue).to receive(:delete)
    
      result = subject.enqueue_and_wait message, :correlation_id => correlation_id
      expect(result).to eq answer
    end
  end
  
end