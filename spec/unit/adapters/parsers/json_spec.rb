RSpec.describe Liberty::Adapters::Parsers::JSON do
  subject(:parser) { described_class }

  describe "#parse" do
    let(:parse) { parser.parse(text) }

    context "when text is nil" do
      let(:text) { nil }

      it "returns an empty hash" do
        expect(parse).to eq({})
      end
    end

    context "when text is NOT nil" do
      context "and the text is NOT valid JSON" do
        let(:text) { "invalid json" }

        it "returns an empty hash" do
          expect(parse).to eq({})
        end
      end

      context "and the text is valid JSON" do
        let(:text) { {key: "value"}.to_json }

        it "returns parsed JSON" do
          expect(parse).to eq({"key" => "value"})
        end
      end
    end
  end
end
