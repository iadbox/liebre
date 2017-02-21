RSpec.describe Liebre::Connection do

  let(:adapter) { double 'adapter' }
  let(:opts)    { double 'opts' }

  subject { described_class.new(adapter, opts) }

  let(:conn) { double 'conn' }

  before do
    allow(adapter).to receive(:connection).
      with(opts).and_return(conn)
  end

  describe '#adapter, #start, #open_channel and #stop' do
    let(:chan) { double 'chan' }

    it 'manages the connection properly' do
      expect(subject.adapter).to eq adapter

      expect(conn).to receive(:start)
      subject.start

      expect(conn).to receive(:open_channel).and_return(chan)
      expect(subject.open_channel).to eq chan

      expect(conn).to receive(:stop)
      subject.stop
    end
  end

end
