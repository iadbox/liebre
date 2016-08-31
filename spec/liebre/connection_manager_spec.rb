require 'spec_helper'

RSpec.describe Liebre::ConnectionManager do
    
  let :connection_path do
    File.expand_path("../../config/rabbitmq.yml" ,__FILE__)
  end

  subject { described_class.new connection_path }

  describe '.start and .get' do

    it do
      subject.start
      
      bunny = subject.get
      
      expect(bunny.connected?).to be true
      
    end
  end

  describe '.restart' do
    
    before do
      subject.start
    end

    it do
      
      subject.restart
      
      bunny = subject.get
      
      expect(bunny.connected?).to be true
      
    end
  end
  
end