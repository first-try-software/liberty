# frozen_string_literal: true

RSpec.describe Liberty::Authenticators::Public do
  describe "#principal" do
    it "returns nil" do
      authenticator = described_class.new
      authenticator.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

      principal = authenticator.principal

      expect(principal).to be_nil
    end
  end

  describe "#challenge_endpoint_class" do
    it "returns nil" do
      authenticator = described_class.new
      authenticator.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

      challenge_endpoint_class = authenticator.challenge_endpoint_class

      expect(challenge_endpoint_class).to be_nil
    end
  end
end
