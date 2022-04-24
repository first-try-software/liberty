RSpec.describe Liberty::Adapters::Parsers::Null do
  subject(:parser) { described_class }

  describe "#parse" do
    subject(:parse) { parser.parse("anything") }

    it "returns nil" do
      expect(parse).to be_nil
    end
  end
end
