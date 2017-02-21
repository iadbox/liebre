RSpec.describe Liebre::Publisher do

  let(:chan) { double 'chan' }

  let(:name) { "foo" }
  let(:opts) { {:durable => false, :auto_delete => true} }

  let :spec do
    double 'spec', :exchange_name => name,
                   :exchange_opts => opts
  end

  subject { described_class.new(chan, spec) }

  let(:exchange) { double 'exchange' }

  before do
    allow(chan).to receive(:exchange).
      with(name, opts).and_return(exchange)
  end

  describe '#__publish__' do
    it 'publishes the message' do
      expect(exchange).to receive(:publish).
        with("some_data", :routing_key => "bar")

      subject.__publish__("some_data", :routing_key => "bar")
    end
  end

end
