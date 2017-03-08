RSpec.describe Liebre::Actor::Consumer do

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
      "bind" => [
        {"routing_key" => "baz"},
        {"routing_key" => "qux"}],
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
          when "do_ack"    then @callback.ack()
          when "do_nack"   then @callback.nack()
          when "do_reject" then @callback.reject(:requeue => true)
          when "fail"      then raise "simulated_crash"
        end
      end

    end
  end

  let :test_extension do
    Class.new do
      include Liebre::Actor::Consumer::Extension

      def on_consume payload, meta, callback
        case payload
          when "cancel_and_ack" then callback.ack(); consume.cancel()
          when "modify"         then consume.continue("do_ack", meta, callback)
          else super
        end
      end

      def after_callback action, _opts
        target.callback(action)
      end

      def after_cancel payload, _meta, _callback
        target.cancel(payload)
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

  let(:queue)    { double 'queue' }
  let(:exchange) { double 'exchange' }

  before do
    allow(chan).to receive(:queue).
      with("bar", :durable => true).
      and_return(queue)

    allow(chan).to receive(:exchange).
      with("foo", "fanout", :durable => true).
      and_return(exchange)
  end

  describe 'starting and handling messages' do
    let! :pool_block do
      # expect queue to bind the exchange
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "baz")

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "qux")

      # expect subscription setup
      pool_block = nil
      expect(queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => true

        pool_block = given_block
      end

      subject.__start__()

      pool_block
    end

    def consume payload
      handler_block = nil
      expect(pool).to receive :post do |&given_block|
        handler_block = given_block
      end

      pool_block.call(:info, :meta, payload)
      handler_block
    end

    context 'standard consumption with ack' do
      it 'handles the message, returns ack and runs after_callback callback' do
        ack_handler_block = consume("do_ack")

        expect(queue).to receive(:ack).
          with(:info, {})

        expect(target).to receive(:callback).
          with(:ack)

        ack_handler_block.()
      end
    end

    context 'standard consumption with reject' do
      it 'handles the message, rejects and runs after_callback callback' do
        reject_handler_block = consume("do_reject")

        expect(queue).to receive(:reject).
          with(:info, :requeue => true)

        expect(target).to receive(:callback).
          with(:reject)

        reject_handler_block.()
      end
    end

    context 'on handler failure' do
      it 'rejects and runs after_callback callback' do
        reject_handler_block = consume("fail")

        expect(queue).to receive(:reject).
          with(:info, {})

        expect(target).to receive(:callback).
          with(:reject)

        reject_handler_block.()
      end
    end

    context 'on extension cancelation' do
      it 'does not call the handler and runs after_cancel callback' do
        expect(target).to receive(:cancel).
          with("cancel_and_ack")

        expect(queue).to receive(:ack).
          with(:info, {})

        expect(target).to receive(:callback).
          with(:ack)

        pool_block.call(:info, :meta, "cancel_and_ack")
      end
    end

    context 'standard consumption with ack' do
      it 'handles the message, returns ack and runs after_callback callback' do
        ack_handler_block = consume("modify")

        expect(queue).to receive(:ack).
          with(:info, {})

        expect(target).to receive(:callback).
          with(:ack)

        ack_handler_block.()
      end
    end
  end

end
