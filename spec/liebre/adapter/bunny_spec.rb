RSpec.describe Liebre::Adapter::Bunny do

  subject { described_class.new }

  describe '#connect and conn methods' do
    let(:opts) { {:host => "localhost"} }

    let(:common_opts) { {:auto_delete => true, :durable => false} }

    it 'everything' do
      # start a connection
      #
      conn    = subject.connection(opts)
      session = conn.session

      expect(conn.opts    ).to eq opts
      expect(session.open?).to eq false

      conn.start
      expect(session.open?).to eq true

      # open a channel
      #
      chan    = conn.open_channel
      channel = chan.channel
      expect(channel.open?).to eq true

      # open an exchange, a queue and bind them
      #
      exchange = chan.exchange("foo", common_opts.merge(:type => "fanout"))
      queue    = chan.queue("bar", common_opts)
      queue.bind(exchange)

      # publish and get message, reject and ack
      #
      exchange.publish("some_data")

      queue.get(:manual_ack => true) do |info, properties, payload|
        expect(payload).to eq "some_data"

        queue.reject(info, :requeue => true)
      end

      queue.get(:manual_ack => true) do |info, properties, payload|
        expect(payload).to eq "some_data"

        queue.ack(info, :requeue => true)
      end

      queue.get(:manual_ack => true) do |*args|
        expect(args).to eq [nil, nil, nil]
      end

      # close a channel
      #
      chan.close
      expect(channel.open?).to eq false

      # stop a connection
      #
      conn.stop
      expect(session.open?).to eq false
    end
  end

end
