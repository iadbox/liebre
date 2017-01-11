require 'spec_helper'

RSpec.describe Liebre::Runner do
    
  let :connection_path do
    File.expand_path("../../config/rabbitmq.yml" ,__FILE__)
  end

  let(:interval) { 1234 }

  subject { described_class.new(interval) }
  let(:logger) { double 'logger' }

  let(:connection_manager) { double 'connection_manager'}

  let(:consumers) { double 'consumers' }

  before do
    Liebre::Config.connection_path = connection_path
    
    allow(subject).to receive(:logger).
      and_return(logger)

    allow(Liebre::ConnectionManager).to receive(:instance).
      and_return(connection_manager)

    allow(described_class::Consumers).to receive(:new).
      with(connection_manager).and_return(consumers)
  end

  describe '#run' do
    it 'logs and retries after fail' do
      expect(connection_manager).to receive(:restart) do
        raise "some error"
      end

      expect(logger).to receive(:warn) do |error|
        expect(error.message).to match /some error/
      end
      expect(subject).to receive(:sleep).with(interval)
      expect(logger).to receive(:warn) do |message|
        expect(message).to match /Retrying/
      end

      expect(connection_manager).to receive(:restart)
      expect(consumers   ).to receive(:start_all)

      expect(subject).to receive(:sleep)

      subject.start
    end
  end
  
end