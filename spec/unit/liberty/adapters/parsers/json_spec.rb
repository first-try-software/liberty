# frozen_string_literal: true

RSpec.describe Liberty::Adapters::Parsers::JSON do
  describe "#parse" do
    context "when text is nil" do
      it "returns an empty hash" do
        parsed = described_class.parse(nil)

        expect(parsed).to eq({})
      end
    end

    context "when text is NOT nil" do
      context "and the text is NOT valid JSON" do
        it "returns an empty hash" do
          parsed = described_class.parse("invalid json")

          expect(parsed).to eq({})
        end
      end

      context "and the text is valid JSON" do
        it "returns parsed JSON" do
          parsed = described_class.parse({key: "value"}.to_json)

          expect(parsed).to eq({"key" => "value"})
        end
      end
    end
  end
end
