require 'spec_helper'

RSpec.describe Liebre::Runner::Starter::Resources do

  let(:connection) { double 'connection' }

  let(:pool_size) { 4 }
  let(:config)    { {"pool_size"  => pool_size} }

  subject { described_class.new(connection, config) }

  describe '#exchange and #queue' do
    let(:channel)     { double 'channel' }
    let(:exchange) { double 'exchange' }

    let(:queue)         { double 'queue' }
    let(:queue_builder) { double 'queue_builder', :queue => queue, :exchange => exchange }

    before do
      allow(connection).to receive(:create_channel).
        with(nil, pool_size).and_return(channel)
      
      allow(channel).to receive(:prefetch).with(10)

      allow(channel).to receive(:default_exchange).
        and_return(exchange)

      allow(described_class::QueueBuilder).to receive(:new).
        with(channel, config).and_return(queue_builder)
    end

    it 'builds exchange and queue properly' do
      expect(subject.exchange).to eq exchange
      expect(subject.queue   ).to eq queue
    end
  end

end
