require 'spec_helper'

RSpec.describe Liebre::ConnectionManager do
    
  let :connection_path do
    File.expand_path("../../config/rabbitmq.yml" ,__FILE__)
  end
  
  before do
    Liebre::Config.connection_path = connection_path
  end

  subject { described_class.instance }

  describe '.start and .get' do

    it do
      subject.start
      
      bunny = subject.get :default
      
      expect(bunny.connected?).to be true
      
    end
  end

  describe '.restart' do
    
    before do
      subject.start
    end

    it do
      
      subject.restart
      
      bunny = subject.get :rpc
      
      expect(bunny.connected?).to be true
      
    end
  end
  
end