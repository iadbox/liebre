RSpec.describe "RPC client-server communication" do

  let(:connections) { {"test_conn" => {}} }

  let :exchange do
    {"name" => "__test__.liebre.rpc_communication_exchange",
     "type" => "fanout",
     "opts" => {:auto_delete => true, :durable => false}}
  end

  let :client_queue do
    {"prefix" => "__test__.liebre.client_rpc_communication_queue"}
  end

  let :server_queue do
    {"name" => "__test__.liebre.server_rpc_communication_queue",
     "opts" => {:auto_delete => true, :durable => false}}
  end

  let :actors do
    {
      "rpc_clients" => {
        "my_client" => {
          "connection" => "test_conn",
          "resources"  => {"exchange" => exchange, "queue" => client_queue}
        }
      },
      "rpc_servers" => {
        "my_server" => {
          "connection"     => "test_conn",
          "prefetch_count" => 5,
          "pool_size"      => 1,
          "handler_class"  => "Liebre::RPCCommunicationTest::HandlerClass",
          "resources"      => {"exchange" => exchange, "queue" => server_queue}
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

  let(:handler_class) { double 'handler_class' }
  let(:handler)       { double 'handler' }

  before do
    allow(Object).to receive(:const_get).
      with("Liebre::RPCCommunicationTest::HandlerClass").
      and_return(handler_class)
  end

  let(:payload) { "some_data" }
  let(:headers) { {"foo" => "bar"} }

  let(:response) { "some_response" }

  it "sends and receives data" do
    engine = Liebre::Engine.new(config)
    engine.start

    repo       = engine.repo
    rpc_client = repo.rpc_client("my_client")

    callback = nil
    expect(handler_class).to receive :new do |payload, meta, given_callback|
      expect(payload     ).to eq payload
      expect(meta.headers).to eq headers
      callback = given_callback

      handler
    end
    expect(handler).to receive :call do
      callback.reply(response)
    end

    sleep(0.1) # wait for all declarations and bindings to take place

    opts = {:headers => headers}
    expect(rpc_client.request(payload, opts, 0.2)).to eq response
  end

end
