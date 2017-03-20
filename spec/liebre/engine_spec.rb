require 'concurrent'

RSpec.describe Liebre::Engine do

  let(:publisher_1_opts) { double 'publisher_1_opts' }
  let(:publisher_2_opts) { double 'publisher_2_opts' }
  let(:consumer_opts)    { double 'consumer_opts' }

  let :actors do
    {:publishers => {
       :one => publisher_1_opts,
       :two => publisher_2_opts},
     :consumers => {
       :three => consumer_opts}}
  end

  let(:config) { double 'config', :actors => actors }

  subject { described_class.new(config) }

  let(:bridge) { double 'bridge' }

  before do
    allow(Liebre::Bridge).to receive(:new).
      with(config).and_return(bridge)
  end

  describe '#start, #clean, #repo and #stop' do
    let(:publisher_1) { double 'publisher_1' }
    let(:publisher_2) { double 'publisher_2' }
    let(:consumer)    { double 'consumer' }

    let(:builder_1) { double 'builder_1', :call => publisher_1 }
    let(:builder_2) { double 'builder_2', :call => publisher_2 }
    let(:builder_3) { double 'builder_3', :call => consumer }

    it 'starts the bridge and all actors' do
      expect(bridge).to receive(:start).
        twice

      expect(described_class::Builder).to receive(:new).
        with(bridge, :publishers, :one, publisher_1_opts, config).
        and_return(builder_1).
        twice

      expect(described_class::Builder).to receive(:new).
        with(bridge, :publishers, :two, publisher_2_opts, config).
        and_return(builder_2).
        twice

      expect(described_class::Builder).to receive(:new).
        with(bridge, :consumers, :three, consumer_opts, config).
        and_return(builder_3).
        twice

      expect(publisher_1).to receive(:start)
      expect(publisher_2).to receive(:start)
      expect(consumer   ).to receive(:start)

      subject.start

      expect(publisher_1).to receive(:clean)
      expect(publisher_2).to receive(:clean)
      expect(consumer   ).to receive(:clean)

      subject.clean

      repo = subject.repo
      expect(repo.publisher(:one) ).to eq publisher_1
      expect(repo.publisher(:two) ).to eq publisher_2
      expect(repo.consumer(:three)).to eq consumer

      repo = subject.repo
      expect(repo.publisher(:one) ).to eq publisher_1
      expect(repo.publisher(:two) ).to eq publisher_2
      expect(repo.consumer(:three)).to eq consumer

      expect(publisher_1).to receive(:stop)
      expect(publisher_2).to receive(:stop)
      expect(consumer   ).to receive(:stop)

      expect(bridge).to receive(:stop)

      subject.stop

      expect(repo.all).to eq []
    end
  end

end
