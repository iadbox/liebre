require 'spec_helper'

RSpec.describe Liebre::Runner do


  let(:interval) { 1234 }

  subject { described_class.new(interval) }
  let(:logger) { double 'logger' }

  let(:conn)         { double 'conn' }
  let(:conn_manager) { double 'conn_manager', :get => conn }

  let(:consumers) { double 'consumers' }

  before do
    
    allow(subject).to receive(:logger).
      and_return(logger)

    allow(Liebre::ConnectionManager).to receive(:new).
      and_return(conn_manager)

    allow(described_class::Consumers).to receive(:new).
      with(conn).and_return(consumers)
  end

  describe '#run' do
    it 'logs and retries after fail' do
      expect(conn_manager).to receive(:restart) do
        raise "some error"
      end

      expect(logger).to receive(:warn) do |error|
        expect(error.message).to match /some error/
      end
      expect(subject).to receive(:sleep).with(interval)
      expect(logger).to receive(:warn) do |message|
        expect(message).to match /Retrying/
      end

      expect(conn_manager).to receive(:restart)
      expect(consumers   ).to receive(:start_all)

      expect(subject).to receive(:sleep)

      subject.start
    end
  end
  
end