RSpec.describe Liebre::Actor::Context::StackBuilder do

  let(:context)   { double 'context' }
  let(:resources) { double 'resources' }
  let(:base)      { double 'base' }

  let(:extension_class_1) { double 'extension_class_1' }
  let(:extension_class_2) { double 'extension_class_2' }

  let :opts do
    {:extensions => [extension_class_1, extension_class_2]}
  end

  subject { described_class.new(context, opts, resources, base) }

  describe '#build' do
    let(:extension_1) { double 'extension_1' }
    let(:extension_2) { double 'extension_2' }

    it 'builds extensions properly' do
      expect(extension_class_2).to receive(:new).
        with(base, resources, context).and_return(extension_2)

      expect(extension_class_1).to receive(:new).
        with(extension_2, resources, context).and_return(extension_1)

      expect(subject.call).to eq extension_1
    end
  end

end
