require 'concurrent'

RSpec.describe Liebre::RPC::Client do

  let(:chan) { double 'chan' }

  let(:exchange_name) { "foo" }
  let(:exchange_opts) { {:durable => false} }
  let(:queue_name)    { "bar" }
  let(:queue_opts)    { {:auto_delete => true} }

  let :spec do
    double 'spec', :exchange_name => exchange_name,
                   :exchange_opts => exchange_opts,
                   :queue_name    => queue_name,
                   :queue_opts    => queue_opts
  end

  subject { described_class.new(chan, spec) }

  let(:response_queue)   { double 'request_queue', :name => "queue_1234" }
  let(:request_exchange) { double 'request_exchange' }

  before do
    allow(chan).to receive(:queue).
      with(queue_name, queue_opts).and_return(response_queue)

    allow(chan).to receive(:exchange).
      with(exchange_name, exchange_opts).and_return(request_exchange)
  end

  describe '#start and #request' do
    let(:expiration_task) { double 'expiration_task' }

    it 'performs requests' do
      # expect subscription setup
      #
      handle_response_block = nil
      expect(response_queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => false

        handle_response_block = given_block
      end

      # expect expiration recurrent task
      #
      expiration_block = nil
      expect(Concurrent::TimerTask).to receive :new do |opts, &given_block|
        expect(opts.has_key?(:execution_interval)).to eq true

        expiration_block = given_block
        expiration_task
      end

      expect(expiration_task).to receive(:execute)

      # start the client
      #
      subject.__start__()

      # perform a request and block until complete
      #
      correlation_id = nil
      expect(request_exchange).to receive :publish do |payload, opts|
        expect(payload).to eq "foo"
        expect(opts[:reply_to]      ).to eq "queue_1234"

        correlation_id = opts[:correlation_id]
      end

      thread = Thread.new(subject) do |subject|
        subject.request("foo", {}, 1000)
      end

      sleep(0.1)
      expect(thread.alive?).to eq true # waiting for response

      # send response that not matches the waiting request
      #
      invalid_meta = double('fake_meta', :correlation_id => "fake_correlation_id")
      handle_response_block.(:info, invalid_meta, "bar")

      sleep(0.1)
      expect(thread.alive?).to eq true # waiting for response

      # send response that matches the waiting request
      #
      valid_meta = double('fake_meta', :correlation_id => correlation_id)
      handle_response_block.(:info, valid_meta, "baz")

      expect(thread.value).to eq "baz"
    end
  end

end
