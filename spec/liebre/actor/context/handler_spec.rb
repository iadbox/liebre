RSpec.describe Liebre::Actor::Context::Handler do

  let(:pool_size)     { 3 }
  let(:handler_class) { double 'handler_class' }

  let :opts do
    {:pool_size => pool_size,
     :handler   => handler_class}
  end

  subject { described_class.new(opts) }

  let(:pool) { double 'pool' }

  before do
    allow(Concurrent::FixedThreadPool).to receive(:new).
      with(pool_size).and_return(pool)
  end

  describe '#call' do
    def pool_block *args, &block
      pool_block = nil
      expect(pool).to receive :post do |&given_block|
        pool_block = given_block
      end

      subject.call(*args, &block)
      pool_block
    end

    let(:handler) { double 'handler' }

    context 'on success' do
      it 'runs the handler on the pool' do
        block = pool_block("foo", "bar") {}

        expect(handler_class).to receive(:new).
          with("foo", "bar").and_return(handler)

        expect(handler).to receive(:call)

        block.()
      end
    end

    context 'on handler error' do
      let(:target) { double 'target' }

      it 'runs the given block with the error as argument' do
        block = pool_block("foo") { target.boom! }

        expect(target).to receive(:boom!)

        expect(handler_class).to receive(:new).
          with("foo").and_return(handler)

        expect(handler).to receive(:call).
          and_raise("boom")

        block.()
      end
    end
  end

end
