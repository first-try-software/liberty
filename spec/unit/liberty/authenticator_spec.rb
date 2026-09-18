# frozen_string_literal: true

RSpec.describe Liberty::Authenticator do
  describe "#inject" do
    it "sets the request" do
      authenticator = described_class.new
      request = Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/"))

      authenticator.inject(request: request)

      expect(authenticator.request).to eq(request)
    end
  end

  describe "#principal" do
    it "must be implemented by a subclass" do
      authenticator = described_class.new

      expect { authenticator.principal }.to raise_error(Liberty::AbstractMethodError, /principal/)
    end
  end

  describe "#challenge_endpoint_class" do
    it "must be implemented by a subclass" do
      authenticator = described_class.new

      expect { authenticator.challenge_endpoint_class }
        .to raise_error(Liberty::AbstractMethodError, /challenge_endpoint_class/)
    end
  end
end
