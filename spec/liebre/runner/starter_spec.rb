require 'spec_helper'

RSpec.describe Liebre::Runner::Starter do

  let(:conn) { double 'conn' }
  
  let(:rpc) { true }

  let(:queue_name) { "some_queue_name" }
  let(:class_name) { "MyRPC" }
  let(:pool_size)  { 4 }

  let :config do
    {
      "queue_name" => queue_name,
      "class_name" => class_name,
      "pool_size"  => pool_size,
      "rpc" => rpc
    }
  end

  let(:exchange) { double 'exchange' }
  let(:queue)    { double 'queue' }
  let(:payload)  { "the_payload" }

  subject { described_class.new(conn, config) }

  let :resources do
    double 'resources', :exchange => exchange, :queue => queue
  end
  
  context "RPC" do

    let(:rpc_class)    { double 'rpc_class' }
    let(:rpc_instance) { double 'rpc_instance' }

    before do
      allow(described_class::Resources).to receive(:new).
        with(conn, config).and_return(resources)

      stub_const(class_name, rpc_class)
    end

    describe '#call' do
      let(:reply_to)       { "queue_to_reply_to" }
      let(:correlation_id) { 123 }

      let :meta do
        double 'meta', :reply_to => reply_to,
          :correlation_id => correlation_id
      end

      let(:response) { "the_response" }

      let :opts do
        {:routing_key => reply_to, :correlation_id => correlation_id}
      end

      it 'calls the rpc_class with a callback' do
        expect(exchange).to receive(:publish).with(response, opts)

        expect(rpc_class).to receive :new do |given_payload, given_meta, options|
          expect(given_payload).to eq payload
          expect(given_meta   ).to eq meta
          options[:callback].(response)

          rpc_instance
        end

        expect(rpc_instance).to receive(:call)

        expect(queue).to receive :subscribe do |&block|
          block.call(:deliver_info, meta, payload)
        end

        subject.call
      end
    end
  end
  
  context "Standard Consumer" do
    
    let(:rpc) { false }
    
    let(:class_name) { "MyConsumer" }

    let(:consumer_class)    { double 'consumer_class' }
    let(:consumer_instance) { double 'consumer_instance' }
    
    let :meta do
      double 'meta'
    end

    before do
      allow(described_class::Resources).to receive(:new).
        with(conn, config).and_return(resources)

      stub_const(class_name, consumer_class)
    end

    it 'calls the consumer_class with a callback' do

      expect(consumer_class).to receive :new do |given_payload, given_meta, options|
        expect(given_payload).to eq payload
        expect(given_meta   ).to eq meta
        expect(options      ).to be_empty

        consumer_instance
      end

      expect(consumer_instance).to receive(:call)

      expect(queue).to receive :subscribe do |&block|
        block.call(:deliver_info, meta, payload)
      end

      subject.call
    end
    
  end
end