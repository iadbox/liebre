require 'spec_helper'

RSpec.describe Liebre::Config do

  let :config_path do
    File.expand_path("../../config/liebre.yml" ,__FILE__)
  end

  let :connection_path do
    File.expand_path("../../config/rabbitmq.yml" ,__FILE__)
  end

  before do
    described_class.config_path     = config_path
    described_class.connection_path = connection_path
    described_class.env = "some_env"
  end

  subject { described_class.new }

  describe '.config_path and .connection_path and .env' do

    it do
      expect(described_class.config_path).to eq config_path
      expect(described_class.connection_path).to eq connection_path
      expect(described_class.env).to eq "some_env"
    end
  end

  describe '#consumers' do

    let(:consumer_names) { %w{ some_consumer some_rpc } }

    let(:consumer_config) do
      {
        'class_name' => "MyConsumer",
        'rpc' => false
      }
    end

    let(:rpc_config) do
      {
        'class_name' => "MyRPC",
        'rpc' => true
      }
    end

    it do

      expect(subject.consumers.keys).to eq consumer_names

      expect(subject.consumers['some_consumer']['class_name']).to eq consumer_config['class_name']
      expect(subject.consumers['some_consumer']['rpc']).to eq consumer_config['rpc']
      expect(subject.consumers['some_consumer']['prefetch_count']).to eq 5

      expect(subject.consumers['some_rpc']['class_name']).to eq rpc_config['class_name']
      expect(subject.consumers['some_rpc']['rpc']).to eq rpc_config['rpc']

    end

  end

end
