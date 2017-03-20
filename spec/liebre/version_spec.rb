RSpec.describe Liebre::VERSION do

  let(:version) { Liebre::VERSION }
  let(:regex)   { /\A\d+\.\d+\.\d+\z/ }

  it 'has semantic format' do
    expect(version).to match regex
  end

end
