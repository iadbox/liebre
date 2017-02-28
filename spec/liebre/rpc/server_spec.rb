RSpec.describe Liebre::RPC::Server do

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

  let(:pool) { double 'pool' }

  subject { described_class.new(chan, spec, handler_class, pool) }

  let(:request_queue)    { double 'request_queue' }
  let(:request_exchange) { double 'request_exchange' }
  let(:default_exchange) { double 'default_exchange' }

  before do
    allow(chan).to receive(:queue).
      with(queue_name, queue_opts).and_return(request_queue)

    allow(chan).to receive(:exchange).
      with(exchange_name, exchange_opts).and_return(request_exchange)

    allow(chan).to receive(:default_exchange).
      and_return(default_exchange)
  end

  describe '#start and #reply' do
    let :meta do
      double 'meta', :reply_to => "foo", :correlation_id => "bar"
    end

    it 'handles requests' do
      # expect queue to bind the exchange
      #
      expect(request_queue).to receive(:bind).
        with(request_exchange)

      # expect subscription setup
      #
      pool_block = nil
      expect(request_queue).to receive :subscribe do |opts, &given_block|
        expect(opts).to eq :block => false, :manual_ack => false

        pool_block = given_block
      end

      # start the consumer
      #
      subject.__start__()

      # preform a request and expect response
      #
      reply_handler_block = nil
      expect(pool).to receive :post do |&given_block|
        reply_handler_block = given_block
      end
      pool_block.call(:info, meta, "payload")

      expect(subject).to receive(:reply).
        with(meta, "response_to(payload)", {})
      reply_handler_block.()

      # simulate reply
      #
      expect(default_exchange).to receive(:publish).
        with("response", :routing_key => "foo", :correlation_id => "bar")

      subject.__reply__(meta, "response")

      # preform a request that fails
      #
      fail_handler_block = nil
      expect(pool).to receive :post do |&given_block|
        fail_handler_block = given_block
      end
      pool_block.call(:info, meta, "fail")

      expect(subject).not_to receive(:reply)
      fail_handler_block.()
    end
  end

end
