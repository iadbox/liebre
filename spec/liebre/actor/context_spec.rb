RSpec.describe Liebre::Actor::Context do

  let(:chan) { double 'chan' }
  let(:name) { "foo" }

  let :opts do
    {
      "resources"     => {"bar" => "baz"},
      "pool_size"     => 3,
      "handler_class" => "Liebre::Actor::Context::TestHandler",
      "extensions"    => ["Liebre::Actor::Context::TestExtension"]
    }
  end

  let(:resources_class) { double 'resources_class' }
  let(:base_class)      { double 'base_class' }

  subject { described_class.new(chan, name, opts, resources_class, base_class) }

  describe '#resources' do
    let(:resources) { double 'resources' }

    it 'builds resources properly' do
      expect(resources_class).to receive(:new).
        with(chan, "bar" => "baz").and_return(resources)

      expect(subject.resources).to eq resources
    end
  end

  describe '#handler' do
    let(:handler_class) { double 'handler_class' }
    let(:handler)       { double 'handler' }

    let(:pool) { double 'pool' }

    before do
      allow(Object).to receive(:const_get).
        with("Liebre::Actor::Context::TestHandler").
        and_return(handler_class)

      allow(Concurrent::FixedThreadPool).to receive(:new).
        with(3).and_return(pool)
    end

    def pool_block *args, &block
      pool_block = nil
      expect(pool).to receive :post do |&block|
        pool_block = block
      end

      subject.handler.call(*args, &block)
      pool_block
    end

    context 'happy path' do
      it 'runs handler properly' do
        pool_block = pool_block("asdf") {}

        expect(handler_class).to receive(:new).
          with("asdf").and_return(handler)

        expect(handler).to receive(:call)

        pool_block.()
      end
    end

    context 'on handler_class error' do
      let(:target) { double 'target' }

      it 'runs the block' do
        pool_block = pool_block("asdf") { target.failed! }

        expect(target).to receive(:failed!)

        expect(handler_class).to receive(:new).
          with("asdf").and_return(handler)

        expect(handler).to receive(:call).
          and_raise("boom")

        pool_block.()
      end
    end
  end

  describe '#extensions' do
    let(:extension_class) { double 'extension_class' }

    before do
      allow(Object).to receive(:const_get).
        with("Liebre::Actor::Context::TestExtension").
        and_return(extension_class)
    end

    let(:extension) { double 'extension' }
    let(:base)      { double 'base' }

    it 'builds extensions properly' do
      expect(base_class).to receive(:new).
        with(nil, subject).and_return(base)

      expect(extension_class).to receive(:new).
        with(base, subject).and_return(extension)

      expect(subject.extensions).to eq extension
    end
  end

end
