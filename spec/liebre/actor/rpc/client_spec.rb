require 'concurrent'

RSpec.describe Liebre::Actor::RPC::Client do

  let(:chan)    { double 'chan' }
  let(:declare) { double 'declare' }

  let :spec do
    {:exchange => {:fake   => "exchange_config"},
     :queue    => {:prefix => "client_test"},
     :bind     => {:fake   => "bind_config"}}
  end

  let(:logger) { double 'logger', :info => nil, :error => nil }

  let :context do
    double 'context', :chan    => chan,
                      :declare => declare,
                      :name    => "foo",
                      :spec    => spec,
                      :logger  => logger
  end

  subject { described_class.new(context) }

  let(:response_queue)   { double 'request_queue', :name => "queue_1234" }
  let(:request_exchange) { double 'request_exchange' }
  let(:task)             { double 'task', :execute => true, :shutdown => true }

  before do
    allow(subject).to receive(:async).and_return(subject)

    allow(declare).to receive :queue do |config|
      expect(config[:name]).to match /^client_test_.+$/
      expect(config[:opts]).to eq :auto_delete => true, :exclusive => true, :durable => false

      response_queue
    end

    allow(declare).to receive(:exchange).
      with(:fake => "exchange_config").and_return(request_exchange)

    allow(Concurrent::TimerTask).to receive(:new).
      with(anything).and_return(task)
  end

  let(:info)     { double 'info' }
  let(:meta)     { double 'meta' }
  let(:payload)  { "some_payload" }
  let(:response) { "some_response" }

  describe '#start' do
    it 'declares queue and exchange, and subscribes to the queue' do
      expect(declare).to receive :queue do |config|
        expect(config[:name]).to match /^client_test_.+$/
        expect(config[:opts]).to eq :auto_delete => true, :exclusive => true, :durable => false

        response_queue
      end

      expect(declare).to receive(:exchange).
        with(:fake => "exchange_config").and_return(request_exchange)

      subscription_block = nil
      expect(response_queue).to receive(:subscribe) do |opts, &block|
        expect(opts).to eq :block => false, :manual_ack => false
        subscription_block = block
      end

      task_block = nil
      expect(Concurrent::TimerTask).to receive(:new) do |opts, &block|
        expect(opts[:execution_interval]).to be_a Numeric
        task_block = block

        task
      end
      expect(task).to receive(:execute)

      subject.start

      expect(subject).to receive(:reply).with(meta, response)
      subscription_block.(info, meta, response)

      expect(subject).to receive(:expire)
      task_block.()
    end
  end

  describe '#clean' do
    it 'deletes queue and exchange' do
      expect(response_queue  ).to receive(:delete)
      expect(request_exchange).to receive(:delete)

      subject.clean
    end
  end

  describe '#request and #reply' do
    it 'replies and releases the client only when a matching response is received' do
      correlation_id = nil
      expect(request_exchange).to receive :publish do |given_payload, opts|
        expect(payload        ).to eq payload
        expect(opts[:reply_to]).to eq "queue_1234"

        correlation_id = opts[:correlation_id]
      end

      thread = Thread.new do
        subject.request(payload)
      end
      sleep(0.1)
      expect(thread.alive?).to eq true # waiting for response

      no_matching_meta = double("not_matching_meta", :correlation_id => "not-matching")
      subject.reply(no_matching_meta, response)
      sleep(0.1)
      expect(thread.alive?).to eq true # waiting for a matching response

      matching_meta = double("matching_meta", :correlation_id => correlation_id)
      subject.reply(matching_meta, response)
      sleep(0.1)
      expect(thread.value).to eq response
    end
  end

end
