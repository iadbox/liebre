require 'concurrent'

RSpec.describe Liebre::Engine::Builder do

  let(:bridge) { double 'bridge' }
  let(:type)   { :publishers }
  let(:name)   { :foo }
  let(:opts)   { double 'opts' }

  let(:context_class)   { double 'context_class' }
  let(:publisher_class) { double 'publisher_class' }

  let :dependencies do
    {:context => context_class,
     :actors  => {:publishers => publisher_class}}
  end

  let(:logger) { double 'logger' }
  let(:config) { double 'config', :logger => logger }

  subject { described_class.new(bridge, type, name, opts, config, dependencies) }

  describe '#call' do
    let(:chan)      { double 'chan' }
    let(:context)   { double 'context' }
    let(:publisher) { double 'publisher' }

    it 'instantiates the actor and the context properly' do
      expect(bridge).to receive(:open_channel).
        with(opts).and_return(chan)

      expect(context_class).to receive(:new).
        with(chan, name, opts, config).and_return(context)

      expect(publisher_class).to receive(:new).
        with(context).and_return(publisher)

      expect(subject.call).to eq publisher
    end
  end

end
