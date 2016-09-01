require 'spec_helper'

RSpec.describe Liebre::Runner::Starter::Resources::QueueBuilder do

  let(:channel) { double 'channel' }

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
     "bind" => {"routing_key" => "foo"}
    }
  end

  subject { described_class.new(channel, config) }

  describe '#call' do
    let(:exchange) { double 'exchange' }
    let(:queue)    { double 'queue' }

    it 'builds and binds the queue properly' do
      expect(channel).to receive(:exchange).
        with("my_exchange", :type => "direct", :an => "option").
        and_return(exchange)

      expect(channel).to receive(:queue).
        with("my_queue", :some => "option").
        and_return(queue)

      expect(queue).to receive(:bind).
        with(exchange, :routing_key => "foo").
        and_return(queue)

      expect(subject.queue).to eq queue
    end
  end

end
