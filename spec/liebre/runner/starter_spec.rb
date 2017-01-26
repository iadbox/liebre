require 'spec_helper'

RSpec.describe Liebre::Runner::Starter do

  let(:connection_manager) { double 'connection_manager' }
  let(:connection)         { double 'connection' }
    let(:consumer)         { double 'consumer' }
  
  let(:rpc) { true }

  let :config do
    {
      "rpc" => rpc,
      "connection_name" => "rpc"
    }
  end
  
  subject { described_class.new(connection_manager, config) }
  
  context "RPC" do
    
    let(:rpc_instance) { double 'rpc_instance' }

    describe '#start and #stop' do
      
      it 'calls the rpc_class with a callback' do
        expect(connection_manager).to receive(:get).with(:rpc).and_return connection
        expect(described_class::RPC).to receive(:new).with(connection, config).and_return rpc_instance
        expect(rpc_instance).to receive(:start).and_return consumer

        subject.start
        
        expect(consumer).to receive(:stop)
        
        subject.stop
        
      end
    end
  end
  
  context "Standard Consumer" do
    
    let(:rpc) { false }
    
    let(:consumer) { double 'consumer' }

    let :config do
      {
        "rpc" => rpc
      }
    end

    describe '#start and #stop' do
      
      it 'calls the rpc_class with a callback' do
        expect(connection_manager).to receive(:get).with(:default).and_return connection
        expect(described_class::Consumer).to receive(:new).with(connection, config).and_return consumer
        expect(consumer).to receive(:start).and_return consumer

        subject.start
        
        expect(consumer).to receive(:stop)
        
        subject.stop
        
      end
    end
    
  end
end