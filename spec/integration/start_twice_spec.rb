RSpec.describe "Start actors twice" do

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

  let :actors do
    {
      :publishers => {
        :my_publisher => {
          :connection => "test_conn",
          :resources  => {:exchange => exchange}
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
    repo = engine.repo

    engine.start(only: [:publishers, :rpc_servers])
    expect(repo.publisher(:my_publisher)).not_to be nil
    expect { repo.consumer(:my_consumer) }.to raise_error KeyError

    engine.start()
    expect(repo.publisher(:my_publisher)).not_to be nil
    expect(repo.consumer(:my_consumer) ).not_to be nil
  end

end
