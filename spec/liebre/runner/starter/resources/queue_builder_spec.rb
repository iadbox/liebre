require 'spec_helper'

RSpec.describe Liebre::Runner::Starter::Resources::QueueBuilder do

  let(:channel) { double 'channel' }
  let(:routing_key) { "foo" }

  let :config do
    {
      "queue" => {
        "name" => "my_queue",
        "opts" => {"some" => "option"}
      },
      "exchange" => {
        "name" => "my_exchange",
        "type" => "direct",
        "opts" => {"an" => "option"}
      },
      "bind" => {"routing_key" => routing_key}
    }
  end
  
  let(:exchange) { double 'exchange' }
  let(:queue)    { double 'queue' }

  subject { described_class.new(channel, config) }

  describe '#call' do

    it 'builds and binds the queue properly' do
      expect(channel).to receive(:exchange).
        with("my_exchange", :type => "direct", :an => "option").
        and_return(exchange)

      expect(channel).to receive(:queue).
        with("my_queue", :some => "option").
        and_return(queue)

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "foo")

      expect(subject.queue).to eq queue
    end
  end
  
  describe "with multiple routing_keys" do
    let(:routing_key) { %W{a b c} }
    
    it 'builds and binds the queue properly' do
      allow(channel).to receive(:exchange).
        with("my_exchange", :type => "direct", :an => "option").
        and_return(exchange)

      expect(channel).to receive(:queue).
        with("my_queue", :some => "option").
        and_return(queue)

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "a")
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "b")
      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "c")

      expect(subject.queue).to eq queue
    end
  end

end
