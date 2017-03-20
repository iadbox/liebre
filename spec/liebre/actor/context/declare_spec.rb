RSpec.describe Liebre::Actor::Context::Declare do

  let(:chan) { double 'chan' }

  subject { described_class.new(chan) }

  describe '#default_exchange' do
    let(:default_exchange) { double 'default_exchange' }

    it 'builds the default exchange' do
      expect(chan).to receive(:default_exchange).
        and_return(default_exchange)

      expect(subject.default_exchange).to eq default_exchange
    end
  end

  describe '#exchange' do
    let(:exchange) { double 'exchange' }

    let :opts do
      {:name => "foo",
       :type => "fanout",
       :opts => {:durable => true}}
    end

    it 'builds an exchange with the given options' do
      expect(chan).to receive(:exchange).
        with("foo", "fanout", :durable => true).
        and_return(exchange)

      expect(subject.exchange(opts)).to eq exchange
    end
  end

  describe '#queue' do
    let(:queue) { double 'queue' }

    let :opts do
      {:name => "foo",
       :opts => {:durable => true}}
    end

    it 'builds an queue with the given options' do
      expect(chan).to receive(:queue).
        with("foo", :durable => true).
        and_return(queue)

      expect(subject.queue(opts)).to eq queue
    end
  end

  describe '#bind' do
    let(:queue)    { double 'queue' }
    let(:exchange) { double 'exchange' }
    let(:opts)     { [{:routing_key => "foo"}, {:routing_key => "bar"}] }

    it 'binds as many option sets as given' do
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "foo")

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "bar")

      subject.bind(queue, exchange, opts)
    end
  end

end
