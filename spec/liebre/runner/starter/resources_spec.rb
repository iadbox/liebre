RSpec.describe Liebre::Runner::Starter::Resources do

  let(:conn) { double 'conn' }

  let(:pool_size) { 4 }
  let(:config)    { {"pool_size"  => pool_size} }

  subject { described_class.new(conn, config) }

  describe '#exchange and #queue' do
    let(:chan)     { double 'chan' }
    let(:exchange) { double 'exchange' }

    let(:queue)         { double 'queue' }
    let(:queue_builder) { double 'queue_builder', :call => queue }

    before do
      allow(conn).to receive(:create_channel).
        with(nil, pool_size).and_return(chan)

      allow(chan).to receive(:default_exchange).
        and_return(exchange)

      allow(described_class::QueueBuilder).to receive(:new).
        with(chan, config).and_return(queue_builder)
    end

    it 'builds exchange and queue properly' do
      expect(subject.exchange).to eq exchange
      expect(subject.queue   ).to eq queue
    end
  end

end
