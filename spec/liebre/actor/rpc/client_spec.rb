require 'concurrent'

RSpec.describe Liebre::Actor::RPC::Client do

  let(:chan)   { double 'chan' }
  let(:target) { double 'target' }

  let :spec do
    {
      "exchange" => {
        "name" => "foo",
        "type" => "fanout",
        "opts" => {"durable" => true}},
      "queue" => {
        "prefix" => "client_test"},
      "extension" => target}
  end

  let :test_extension do
    Class.new do
      include Liebre::Actor::RPC::Client::Extension

      def on_request _tag, payload, _opts
        case payload
          when "direct_reply" then request.reply("direct_response")
          else super
        end
      end

      def after_request _tag, payload, _opts
        target.request(payload)
      end

      def on_reply _tag, response
        case response
          when "modify" then reply.continue("modified")
          else super
        end
      end

      def after_reply _tag, response
        target.reply(response)
      end

      def target
        context.spec["extension"]
      end

    end
  end

  subject { described_class.new(chan, spec, [test_extension]) }

  let(:response_queue)   { double 'request_queue', :name => "queue_1234" }
  let(:request_exchange) { double 'request_exchange' }

  before do
    allow(chan).to receive :queue do |name, opts|
      expect(name).to match /^client_test_.+$/
      expect(opts).to eq :auto_delete => true, :exclusive => true, :durable => false

      response_queue
    end

    allow(chan).to receive(:exchange).
      with("foo", "fanout", :durable => true).
      and_return(request_exchange)
  end

  describe 'starting and performing requests' do
    let! :startup_blocks do
      # expect subscription setup
      handle_response_block = nil
      expect(response_queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => false

        handle_response_block = given_block
      end

      # expect expiration recurrent task
      expiration_block = nil
      expect(Concurrent::TimerTask).to receive :new do |opts, &given_block|
        expect(opts.has_key?(:execution_interval)).to eq true

        expiration_block = given_block
        expiration_task
      end
      expect(expiration_task).to receive(:execute)

      subject.__start__()

      [handle_response_block, expiration_block]
    end

    let(:handle_response_block) { startup_blocks.first }
    let(:expiration_block)      { startup_blocks.last }

    let(:expiration_task) { double 'expiration_task' }

    it 'sets up the expiration block' do
      expect(subject).to receive(:expire)

      expiration_block.()
    end

    context 'standard request-response' do
      it 'blocks until receives the correct response' do
        # perform a request and block until response
        correlation_id = nil
        expect(request_exchange).to receive :publish do |payload, opts|
          expect(payload        ).to eq "foo"
          expect(opts[:reply_to]).to eq "queue_1234"

          correlation_id = opts[:correlation_id]
        end

        expect(target).to receive(:request).
          with("foo")

        thread = Thread.new(subject) do |subject|
          subject.request("foo", {}, 1000)
        end

        sleep(0.1)
        expect(thread.alive?).to eq true # waiting for response

        # send response that not matches the pending request
        #
        expect(target).to receive(:reply).
          with("bar")

        invalid_meta = double('fake_meta', :correlation_id => "fake_correlation_id")
        handle_response_block.(:info, invalid_meta, "bar")

        sleep(0.1)
        expect(thread.alive?).to eq true # waiting for response

        # send response that matches the pending request
        #
        expect(target).to receive(:reply).
          with("baz")

        valid_meta = double('fake_meta', :correlation_id => correlation_id)
        handle_response_block.(:info, valid_meta, "baz")

        sleep(0.1)
        expect(thread.value).to eq "baz"
      end
    end

    context 'when an extension replies directly' do
      it 'responds and runs after_reply callback' do
        expect(target).to receive(:reply).
          with("direct_response")

        expect(subject.request("direct_reply", {}, 1000)).to eq "direct_response"
      end
    end

    context 'when an extension modifies the response' do
      it 'responds properly and runs callbacks' do
        # perform a request and block until response
        correlation_id = nil
        expect(request_exchange).to receive :publish do |payload, opts|
          expect(payload        ).to eq "foo"
          expect(opts[:reply_to]).to eq "queue_1234"

          correlation_id = opts[:correlation_id]
        end

        expect(target).to receive(:request).
          with("foo")

        thread = Thread.new(subject) do |subject|
          subject.request("foo", {}, 1000)
        end
        sleep(0.2)

        # send response that matches the pending request
        #
        expect(target).to receive(:reply).
          with("modified")

        valid_meta = double('fake_meta', :correlation_id => correlation_id)
        handle_response_block.(:info, valid_meta, "modify")

        sleep(0.2)
        expect(thread.value).to eq "modified"
      end
    end
  end

end
