RSpec.describe Liebre::Bridge do

  let(:adapter) { double 'adapter' }

  let(:name_1) { :foo }
  let(:name_2) { :bar }
  let(:opts_1) { double 'opts_1' }
  let(:opts_2) { double 'opts_2' }

  let(:connections) { {name_1 => opts_1, name_2 => opts_2}}

  let :config do
    double 'config', :adapter     => adapter,
                     :connections => connections
  end

  subject { described_class.new(config) }

  let(:conn_1) { double 'conn_1' }
  let(:conn_2) { double 'conn_2' }

  before do
    allow(adapter).to receive(:connection).
      with(opts_1).and_return(conn_1)

    allow(adapter).to receive(:connection).
      with(opts_2).and_return(conn_2)
  end

  describe '#open_channel' do
    let(:chan) { double 'chan' }

    let :chan_opts do
      {:connection => name_2, :prefetch_count => 8}
    end

    it 'opens configured channels' do
      expect(conn_1).to receive(:start)
      expect(conn_2).to receive(:start)
      subject.start

      expect(conn_2).to receive(:open_channel).
        and_return(chan)
      expect(chan).to receive(:set_prefetch).
        with(chan_opts[:prefetch_count])

      expect(subject.open_channel(chan_opts)).to eq chan
    end
  end

end
