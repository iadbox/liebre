RSpec.describe Liebre::Actor::RPC::Server do

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

  let(:request_queue)     { double 'request_queue' }
  let(:request_exchange)  { double 'request_exchange' }
  let(:response_exchange) { double 'response_exchange' }

  before do
    allow(subject).to receive(:async).and_return(subject)

    allow(declare).to receive(:queue).
      with(:fake => "queue_config").and_return(request_queue)

    allow(declare).to receive(:exchange).
      with(:fake => "exchange_config").and_return(request_exchange)

    allow(declare).to receive(:default_exchange).
      and_return(response_exchange)

    allow(declare).to receive(:bind).
      with(request_queue, request_exchange, :fake => "bind_config")

    allow(context).to receive(:build_stack) do |resources, base|
      expect(resources.request_queue    ).to eq request_queue
      expect(resources.request_exchange ).to eq request_exchange
      expect(resources.response_exchange).to eq response_exchange
      base
    end
  end

  let(:info)    { double 'info' }
  let(:payload) { "some_data" }

  let :meta do
    double 'meta', :reply_to       => "reply.queue",
                   :correlation_id => "123"
  end

  describe '#start' do
    it 'declares and binds queue and exchange, and subscribes to the queue' do
      expect(declare).to receive(:queue).
        with(:fake => "queue_config").and_return(request_queue)

      expect(declare).to receive(:exchange).
        with(:fake => "exchange_config").and_return(request_exchange)

      expect(declare).to receive(:default_exchange).
        and_return(response_exchange)

      expect(declare).to receive(:bind).
        with(request_queue, request_exchange, :fake => "bind_config")

      subscription_block = nil
      expect(request_queue).to receive(:subscribe) do |opts, &block|
        expect(opts).to eq :block => false, :manual_ack => false
        subscription_block = block
      end

      subject.start

      expect(subject).to receive(:handle).
        with(meta, payload)

      subscription_block.(info, meta, payload)
    end
  end

  describe '#handle' do
    context 'on success' do
      let(:response) { "some_response" }

      it 'runs the handler with a callback object' do
        callback = nil
        expect(handler).to receive :call do |given_payload, given_meta, given_callback|
          expect(given_payload).to eq payload
          expect(given_meta   ).to eq meta

          callback = given_callback
        end

        subject.handle(meta, payload)

        expect(subject).to receive(:reply).with(meta, "some_response", {})
        callback.reply(response)
      end
    end

    context 'on handler failure' do
      let(:error) { double 'error' }

      it 'calls failed on the server' do
        error_block = nil
        expect(handler).to receive :call do |payload, meta, callback, &block|
          error_block = block
        end

        subject.handle(meta, payload)

        expect(subject).to receive(:failed).
          with(meta, error)

        error_block.(error)
      end
    end
  end

  describe '#reply' do
    let(:response) { "some_response" }

    it 'delegates to the queue' do
      expect(response_exchange).to receive(:publish).
        with(response, :routing_key => "reply.queue", :correlation_id => "123")
      subject.reply(meta, response)
    end
  end

end
