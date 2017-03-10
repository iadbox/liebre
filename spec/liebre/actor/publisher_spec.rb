# RSpec.describe Liebre::Actor::Publisher do
#
#   let(:chan) { double 'chan' }
#
#   let :spec do
#     {
#       "exchange" => {
#         "name" => "foo",
#         "type" => "fanout",
#         "opts" => {"durable" => true}}}
#   end
#
#   let :test_extension do
#     Class.new do
#       include described_class::Extension
#
#     end
#   end
#
#   subject { described_class.new(chan, spec) }
#
#   let(:exchange) { double 'exchange' }
#
#   before do
#     allow(chan).to receive(:exchange).
#       with("foo", "fanout", :durable => true).
#       and_return(exchange)
#   end
#
#   describe '#__publish__' do
#     it 'publishes the message' do
#       expect(exchange).to receive(:publish).
#         with("some_data", :routing_key => "bar")
#
#       subject.__publish__("some_data", :routing_key => "bar")
#     end
#   end
#
# end
