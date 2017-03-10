RSpec.describe Liebre::Actor::Consumer do

  let(:chan) { double 'chan' }

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
        {"routing_key" => "qux"}]}
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

  let(:pool) { double 'pool' }

  subject { described_class.new(chan, spec, handler_class, pool) }

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

  describe 'everything' do
    before do
      allow(subject).to receive(:async).and_return(subject)
    end
    it 'starts, stops and acks' do
      # expect queue to bind the exchange
      #
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "baz")

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "qux")

      # expect subscription setup
      #
      pool_block = nil
      expect(queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => true

        pool_block = given_block
      end

      # start the consumer
      #
      subject.__start__()

      # handle message that will ack
      #
      ack_handler_block = nil
      expect(pool).to receive :post do |&given_block|
        ack_handler_block = given_block
      end
      pool_block.call(:info, :meta, "do_ack")

      expect(subject).to receive(:ack).with(:info, {})
      ack_handler_block.()

      # handle message that will reject
      #
      reject_handler_block = nil
      expect(pool).to receive :post do |&given_block|
        reject_handler_block = given_block
      end
      pool_block.call(:info, :meta, "do_reject")

      expect(subject).to receive(:reject).with(:info, :requeue => true)
      reject_handler_block.()

      # handle message that will reject because of a failure
      #
      reject_handler_block = nil
      expect(pool).to receive :post do |&given_block|
        reject_handler_block = given_block
      end
      pool_block.call(:info, :meta, "fail")

      expect(subject).to receive(:reject).with(:info, {})
      reject_handler_block.()
    end
  end

end
