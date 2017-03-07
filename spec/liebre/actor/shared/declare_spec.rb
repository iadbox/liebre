RSpec.describe Liebre::Actor::Shared::Declare do

  let(:chan) { double 'chan' }

  subject { described_class.new(chan) }

  describe '#exchange' do
    let :config do
      {"name" => "foo",
       "type" => "fanout",
       "opts" => {"durable" => true, "auto_delete" => false}}
    end

    let(:exchange) { double 'exchange' }

    it 'declares an exchange' do
      expect(chan).to receive(:exchange).
        with("foo", "fanout", :durable => true, :auto_delete => false).
        and_return(exchange)

      expect(subject.exchange(config)).to eq exchange
    end
  end

  describe '#queue' do
    let :config do
      {"name" => "foo",
       "opts" => {"durable" => false, "exclusive" => true}}
    end

    let(:queue) { double 'queue' }

    it 'declares an queue' do
      expect(chan).to receive(:queue).
        with("foo", :durable => false, :exclusive => true).
        and_return(queue)

      expect(subject.queue(config)).to eq queue
    end
  end

  describe '#bind' do
    let :config do
      [{"routing_key" => "foo"}, {"routing_key" => "bar"}]
    end

    let(:queue)    { double 'queue' }
    let(:exchange) { double 'exchange' }

    it 'binds a queue and an exchange' do
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "foo")

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "bar")

      subject.bind(queue, exchange, config)
    end
  end

end
