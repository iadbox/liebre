RSpec.describe Liebre::Actor::RPC::Server do

  let(:chan)   { double 'chan' }
  let(:target) { double 'target' }

  let(:exchange_name) { "foo" }
  let(:exchange_opts) { {:durable => false} }
  let(:queue_name)    { "bar" }
  let(:queue_opts)    { {:auto_delete => true} }

  let :spec do
    {
      "exchange" => {
        "name" => "foo",
        "type" => "fanout",
        "opts" => {"durable" => true}},
      "queue" => {
        "name" => "bar",
        "opts" => {"durable" => true}},
      "bind" => {
        "routing_key" => "baz"},
      "extension" => target}
  end

  let :handler_class do
    Class.new do

      def initialize payload, _meta, callback
        @payload  = payload
        @callback = callback
      end

      def call
        case @payload
          when "fail" then raise "simulated_crash"
          else @callback.reply("response_to(#{@payload})")
        end
      end

    end
  end

  let :test_extension do
    Class.new do
      include Liebre::Actor::RPC::Server::Extension

      def on_request _tag, payload, opts, callback
        case payload
          when "reply_and_cancel" then callback.reply("direct_reply"); request.cancel()
          else super
        end
      end

      def on_reply _tag, response, opts
        case response
          when "response_to(modify)" then reply.continue("modified", opts)
          else super
        end
      end

      def after_reply _tag, response, _opts
        target.reply(response)
      end

      def on_failure _tag, _error
        failure.reply("failed")
      end

      def target
        context.spec["extension"]
      end

    end
  end

  let(:pool) { double 'pool' }

  subject { described_class.new(chan, spec, handler_class, pool, [test_extension]) }

  before do
    allow(subject).to receive(:async).and_return(subject)
  end

  let(:request_queue)    { double 'request_queue' }
  let(:request_exchange) { double 'request_exchange' }
  let(:default_exchange) { double 'default_exchange' }

  before do
    allow(chan).to receive(:queue).
      with("bar", :durable => true).
      and_return(request_queue)

    allow(chan).to receive(:exchange).
      with("foo", "fanout", :durable => true).
      and_return(request_exchange)

    allow(chan).to receive(:default_exchange).
      and_return(default_exchange)
  end

  describe 'starting and handling messages' do
    let! :pool_block do
      # expect queue to bind the exchange
      expect(request_queue).to receive(:bind).
        with(request_exchange, :routing_key => "baz")

      # expect subscription setup
      pool_block = nil
      expect(request_queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => false

        pool_block = given_block
      end

      subject.__start__()

      pool_block
    end

    def handle payload
      handler_block = nil
      expect(pool).to receive :post do |&given_block|
        handler_block = given_block
      end
      pool_block.call(info, meta, payload)

      handler_block
    end

    let(:info)  { double 'info', :delivery_tag => 54321 }
    let (:meta) { double 'meta', :reply_to => "foo", :correlation_id => "bar" }

    context 'standard message' do
      it 'responds properly and runs after_reply callback' do
        reply_handler_block = handle("payload")

        expect(default_exchange).to receive(:publish).
          with("response_to(payload)", :routing_key => "foo", :correlation_id => "bar")

        expect(target).to receive(:reply).
          with("response_to(payload)")

        reply_handler_block.()
        sleep(0.2)
      end
    end

    context 'on failure' do
      it 'calls on_failure that replies, and runs after_reply callback' do
        fail_handler_block = handle("fail")

        expect(default_exchange).to receive(:publish).
          with("failed", :routing_key => "foo", :correlation_id => "bar")

        expect(target).to receive(:reply).
          with("failed")

        sleep(0.2)
        fail_handler_block.()
      end
    end

    context 'with an extension replying directly without calling the handler' do
      it 'replies directly and runs after_reply callback' do
        expect(default_exchange).to receive(:publish).
          with("direct_reply", :routing_key => "foo", :correlation_id => "bar")

        expect(target).to receive(:reply).
          with("direct_reply")

        pool_block.call(info, meta, "reply_and_cancel")
      end
    end

    context 'with an extension modifying the response' do
      it 'replies with the modified response' do
        reply_handler_block = handle("modify")

        expect(default_exchange).to receive(:publish).
          with("modified", :routing_key => "foo", :correlation_id => "bar")

        expect(target).to receive(:reply).
          with("modified")

        reply_handler_block.()
        sleep(0.2)
      end
    end
  end

end
