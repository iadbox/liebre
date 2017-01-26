require 'spec_helper'

RSpec.describe Liebre::Runner::Consumers do

  let(:conn) { double 'conn' }

  let(:first_expected_config)  do 
    {
      "class_name" => "MyConsumer",
      "num_threads" => 3,
      "rpc" => false
    } 
  end
    
  let(:second_expected_config) do 
    {
      "class_name" => "MyRPC",
      "rpc" => true
    }
  end
  
  let(:consumers_config) do 
    {
      "some_consumer" => first_expected_config,
      "some_rpc" => second_expected_config
    }
  end
    
  before do
    allow(subject).to receive(:consumers).and_return consumers_config
  end

  subject { described_class.new(conn) }

  describe "#consumer_names" do
    it "returns all names" do
      expect(subject.consumer_names).to eq ["some_consumer", "some_rpc"]
    end
  end

  describe "#start_all" do
    let(:first_starter)  { double 'first_starter' }
    let(:second_starter) { double 'second_starter' }

    it "starts the given consumers" do
      expect(Liebre::Runner::Starter).to receive(:new).exactly(3).times.
        with(conn, first_expected_config).and_return(first_starter)

      expect(Liebre::Runner::Starter).to receive(:new).
        with(conn, second_expected_config).and_return(second_starter)

      expect(first_starter ).to receive(:start).exactly(3).times
      expect(second_starter).to receive(:start)

      subject.start_all
    end
  end

end
