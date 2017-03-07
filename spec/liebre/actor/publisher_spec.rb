RSpec.describe Liebre::Actor::Publisher do

  let(:chan)   { double 'chan' }
  let(:target) { double 'target' }

  let :spec do
    {
      "exchange" => {
        "name" => "foo",
        "type" => "fanout",
        "opts" => {"durable" => true}},
      "extension" => target}
  end

  let :test_extension do
    Class.new do
      include Liebre::Actor::Publisher::Extension

      def on_publication payload, opts
        case payload
          when "cancel"   then publication.cancel
          when "override" then publication.continue("overriden", opts)
          when "modify"   then stack.on_publication(payload, {})
          else stack.on_publication(payload, opts)
        end
      end

      def after_publish payload, opts
        target.published(payload)
      end

      def after_cancel payload, opts
        target.canceled(payload)
      end

      def target
        context.spec["extension"]
      end
    end
  end

  subject { described_class.new(chan, spec, [test_extension]) }

  let(:exchange) { double 'exchange' }

  before do
    allow(chan).to receive(:exchange).
      with("foo", "fanout", :durable => true).
      and_return(exchange)
  end

  describe '#__publish__' do
    it 'publishes the message' do
      # standard publication
      #
      expect(exchange).to receive(:publish).
        with("some_data", :routing_key => "bar")

      expect(target).to receive(:published).
        with("some_data",)

      subject.__publish__("some_data", :routing_key => "bar")

      # cancel
      #
      expect(target).to receive(:canceled).with("cancel",)
      subject.__publish__("cancel", :routing_key => "bar")

      # override publication
      #
      expect(exchange).to receive(:publish).
        with("overriden", :routing_key => "bar")

      expect(target).to receive(:published).
        with("overriden")

      subject.__publish__("override", :routing_key => "bar")

      # modify publication
      #
      expect(exchange).to receive(:publish).
        with("modify", {})

      expect(target).to receive(:published).
        with("modify")

      subject.__publish__("modify", :routing_key => "bar")
    end
  end

end
