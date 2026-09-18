# frozen_string_literal: true

RSpec.describe Liberty::Adapters::Parsers::Null do
  describe "#parse" do
    it "returns nil" do
      parsed = described_class.parse("anything")

      expect(parsed).to be_nil
    end
  end
end
