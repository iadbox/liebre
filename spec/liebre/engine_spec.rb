RSpec.describe Liebre::Engine do

  let :actors do
    {
      "publishers" => {
        "first" => {
          "connection" => "conn_1",
          "resources"  => "first_resources"
        },
        "second" => {
          "connection" => "conn_2",
          "resources"  => "second_resources"
        }
      },
      "consumers" => {
        "third" => {
          "connection"     => "conn_1",
          "prefetch_count" => 15,
          "pool_size"      => 16,
          "handler_class"  => "Test::MyHandler",
          "resources"      => "third_resources"
        }
      }
    }
  end

  let(:config) { double 'config', :actors => actors }

  subject { described_class.new(config) }

  let(:bridge) { double 'bridge' }

  let(:chan_1) { double 'chan_1' }
  let(:chan_2) { double 'chan_2' }
  let(:chan_3) { double 'chan_3' }

  let(:handler_class) { double 'handler_class' }

  before do
    allow(Liebre::Bridge).to receive(:new).
      with(config).and_return(bridge)

    allow(bridge).to receive(:open_channel).
      with(actors["publishers"]["first"]).and_return(chan_1)
    allow(bridge).to receive(:open_channel).
      with(actors["publishers"]["second"]).and_return(chan_2)
    allow(bridge).to receive(:open_channel).
      with(actors["consumers"]["third"]).and_return(chan_3)

    allow(Object).to receive(:const_get).
      with("Test::MyHandler").and_return(handler_class)
  end

  describe '#start' do
    let(:first_publisher)  { double 'first_publisher' }
    let(:second_publisher) { double 'second_publisher' }
    let(:third_consumer)   { double 'third_consumer' }

    let(:publisher_class) { Liebre::Actor::Publisher }
    let(:consumer_class)  { Liebre::Actor::Consumer }

    it 'starts actors properly' do
      expect(publisher_class).to receive(:new).
        with(chan_1, "first_resources").and_return(first_publisher)
      expect(publisher_class).to receive(:new).
        with(chan_2, "second_resources").and_return(second_publisher)

      expect(consumer_class).to receive :new do |chan, resources, handler, pool|
        expect(chan     ).to eq chan_3
        expect(resources).to eq "third_resources"
        expect(handler  ).to eq handler_class

        third_consumer
      end

      expect(bridge          ).to receive(:start)
      expect(first_publisher ).to receive(:start)
      expect(second_publisher).to receive(:start)
      expect(third_consumer  ).to receive(:start)
      subject.start

      repo = subject.repo
      expect(repo.publisher("first") ).to eq first_publisher
      expect(repo.publisher("second")).to eq second_publisher
      expect(repo.consumer("third")  ).to eq third_consumer
    end
  end

end
