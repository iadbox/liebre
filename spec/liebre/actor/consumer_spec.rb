RSpec.describe Liebre::Actor::Consumer do

  let(:chan)    { double 'chan' }
  let(:declare) { double 'declare' }
  let(:handler) { double 'handler' }

  let :spec do
    {:exchange => {:fake => "exchange_config"},
     :queue    => {:fake => "queue_config"},
     :bind     => {:fake => "bind_config"}}
  end

  let :context do
    double 'context', :chan    => chan,
                      :declare => declare,
                      :handler => handler,
                      :spec    => spec
  end

  subject { described_class.new(context) }

  let(:queue)    { double 'queue' }
  let(:exchange) { double 'exchange' }

  before do
    allow(subject).to receive(:async).and_return(subject)

    allow(declare).to receive(:queue).
      with(:fake => "queue_config").and_return(queue)

    allow(declare).to receive(:exchange).
      with(:fake => "exchange_config").and_return(exchange)

    allow(declare).to receive(:bind).
      with(queue, exchange, :fake => "bind_config")
  end

  let(:info)    { double 'info' }
  let(:meta)    { double 'meta' }
  let(:payload) { "some_data" }

  describe '#start' do
    it 'declares and binds queue and exchange, and subscribes to the queue' do
      expect(declare).to receive(:queue).
        with(:fake => "queue_config").and_return(queue)

      expect(declare).to receive(:exchange).
        with(:fake => "exchange_config").and_return(exchange)

      expect(declare).to receive(:bind).
        with(queue, exchange, :fake => "bind_config")

      subscription_block = nil
      expect(queue).to receive(:subscribe) do |opts, &block|
        expect(opts).to eq :block => false, :manual_ack => true
        subscription_block = block
      end

      subject.start

      expect(subject).to receive(:consume).
        with(info, meta, payload)

      subscription_block.(info, meta, payload)
    end
  end

  describe '#consume' do
    context 'on success' do
      it 'runs the handler with a callbacks object' do
        callback = nil
        expect(handler).to receive :call do |given_payload, given_meta, given_callback|
          expect(given_payload).to eq payload
          expect(given_meta   ).to eq meta

          callback = given_callback
        end

        subject.consume(info, meta, payload)

        expect(subject).to receive(:ack).with(info, {})
        callback.ack()

        expect(subject).to receive(:nack).with(info, {})
        callback.nack()

        expect(subject).to receive(:reject).with(info, :requeue => true)
        callback.reject(:requeue => true)
      end
    end

    context 'on handler failure' do
      let(:error) { double 'error' }

      it 'calls failed on the consumer' do
        error_block = nil
        expect(handler).to receive :call do |payload, meta, callback, &block|
          error_block = block
        end

        subject.consume(info, meta, payload)

        expect(subject).to receive(:failed).
          with(info, error)

        error_block.(error)
      end
    end
  end

  describe '#ack, #nack, #reject and #failed' do
    it 'delegates to the queue' do
      expect(queue).to receive(:ack).with(info, {})
      subject.ack(info)

      expect(queue).to receive(:nack).with(info, {})
      subject.nack(info)

      expect(queue).to receive(:reject).with(info, :requeue => true)
      subject.reject(info, :requeue => true)

      expect(queue).to receive(:reject).with(info, {})
      subject.failed(info, :some_error)
    end
  end

end
