require 'spec_helper'

RSpec.describe Liebre::Runner::Starter do

  let(:conn) { double 'conn' }
  
  let(:rpc) { true }

  let :config do
    {
      "rpc" => rpc
    }
  end
  
  subject { described_class.new(conn, config) }
  
  context "RPC" do
    
    let(:rpc_instance) { double 'rpc_instance' }

    describe '#call' do
      
      it 'calls the rpc_class with a callback' do
        expect(described_class::RPC).to receive(:new).with(conn, config).and_return rpc_instance
        expect(rpc_instance).to receive(:call)

        subject.call
      end
    end
  end
  
  context "Standard Consumer" do
    
    let(:rpc) { false }
    
    let(:consumer) { double 'consumer' }

    describe '#call' do
      
      it 'calls the rpc_class with a callback' do
        expect(described_class::Consumer).to receive(:new).with(conn, config).and_return consumer
        expect(consumer).to receive(:call)

        subject.call
      end
    end
    
  end
end