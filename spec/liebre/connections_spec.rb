RSpec.describe Liebre::Connections do

  let(:adapter) { double 'adapter' }

  let(:name_1) { "main" }
  let(:name_2) { "other" }

  let(:opts_1) { double 'opts_1' }
  let(:opts_2) { double 'opts_2' }

  let(:connections) { {name_1 => opts_1, name_2 => opts_2} }

  let :config do
    double 'config', :adapter     => adapter,
                     :connections => connections
  end

  subject { described_class.new(config) }

  let(:connection_1) { double 'connection_1' }
  let(:connection_2) { double 'connection_2' }

  before do
    allow(adapter).to receive(:connection).
      with(opts_1).and_return(connection_1)

    allow(adapter).to receive(:connection).
      with(opts_2).and_return(connection_2)
  end

  describe '#start, #get, #all, and #stop' do
    it 'starts and stops every connection' do
      expect(connection_1).to receive(:start)
      expect(connection_2).to receive(:start)
      subject.start

      expect(subject.all).to eq name_1 => connection_1,
                                name_2 => connection_2

      expect(subject.fetch(name_2)).to eq connection_2

      expect(connection_1).to receive(:stop)
      expect(connection_2).to receive(:stop)
      subject.stop
    end
  end

end
