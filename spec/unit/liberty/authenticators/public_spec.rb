# frozen_string_literal: true

RSpec.describe Liberty::Authenticators::Public do
  describe ".principal" do
    subject(:principal) { described_class.principal(request) }

    let(:request) { instance_double("request") }

    it "returns nil" do
      expect(principal).to be_nil
    end
  end

  describe ".challenge" do
    subject(:challenge) { described_class.challenge }

    it "returns nil" do
      expect(challenge).to be_nil
    end
  end
end
