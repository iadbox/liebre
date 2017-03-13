RSpec.describe Liebre::Actor::Publisher do

  let(:chan)    { double 'chan' }
  let(:declare) { double 'declare' }
  let(:spec)    { {:exchange => {:fake => "config"}} }

  let :context do
    double 'context', :chan    => chan,
                      :declare => declare,
                      :spec    => spec
  end

  subject { described_class.new(context) }

  before do
    allow(subject).to receive(:async).and_return(subject)
  end

  let(:exchange) { double 'exchange' }

  describe '#start' do
    it 'declares the exchange' do
      expect(declare).to receive(:exchange).
        with(:fake => "config").and_return(exchange)

      subject.start
    end
  end

  describe '#publish' do
    it 'publishes through the exchange' do
      allow(declare).to receive(:exchange).
        with(:fake => "config").and_return(exchange)

      expect(exchange).to receive(:publish).
        with("some_data", :routing_key => "bar")

      subject.publish("some_data", :routing_key => "bar")
    end
  end

end
