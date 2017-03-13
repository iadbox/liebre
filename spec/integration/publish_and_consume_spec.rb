RSpec.describe "Publish and consume" do

  let(:connections) { {"test_conn" => {}} }

  let :exchange do
    {:name => "__test__.liebre.publish_and_consume_exchange",
     :type => "fanout",
     :opts => {:auto_delete => true, :durable => false}}
  end

  let :queue do
    {:name => "__test__.liebre.publish_and_consume_queue",
     :opts => {:auto_delete => true, :durable => false}}
  end

  let(:handler_class) { double 'handler_class' }
  let(:handler)       { double 'handler' }

  let :header_extension do
    Class.new do
      include Liebre::Actor::Publisher::Extension

      def publish payload, opts
        opts[:headers] = opts.
          fetch(:headers, {}).
          merge!("baz" => "qux")

        stack.publish(payload, opts)
      end
    end
  end

  let :actors do
    {
      :publishers => {
        :my_publisher => {
          :connection => "test_conn",
          :resources  => {:exchange => exchange},
          :extensions => [header_extension]
        }
      },
      :consumers => {
        :my_consumer => {
          :connection     => "test_conn",
          :prefetch_count => 5,
          :pool_size      => 1,
          :handler        => handler_class,
          :resources      => {:exchange => exchange, :queue => queue}
        }
      }
    }
  end

  let :config do
    Liebre::Config.new.tap do |config|
      config.adapter     = Liebre::Adapter::Bunny
      config.connections = connections
      config.actors      = actors
    end
  end

  let(:payload) { "some_data" }
  let(:headers) { {"foo" => "bar"} }

  it "sends and receives data" do
    engine = Liebre::Engine.new(config)
    engine.start

    repo      = engine.repo
    publisher = repo.publisher(:my_publisher)

    expect(handler_class).to receive :new do |payload, meta, callback|
      expect(payload     ).to eq payload
      expect(meta.headers).to eq headers.merge("baz" => "qux")

      handler
    end
    expect(handler).to receive(:call)

    sleep(0.1) # wait for the consumer to bind its queue to the exchange
    publisher.publish(payload, :headers => headers)

    sleep(0.2) # wait for the message to be published and consumed
  end

end
