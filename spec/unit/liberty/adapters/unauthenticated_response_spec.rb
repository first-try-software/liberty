# frozen_string_literal: true

RSpec.describe Liberty::Adapters::UnauthenticatedResponse do
  describe "#to_rack_response" do
    subject(:to_rack_response) { described_class.new(endpoint).to_rack_response }

    let(:endpoint) { Class.new(Liberty::Endpoint).new }
    let(:request) { instance_double(Liberty::Adapters::Request, head?: false) }

    before { endpoint.inject(request: request) }

    it "returns a 401 status" do
      expect(to_rack_response).to match_array([401, anything, anything])
    end

    it "returns a text/plain content type" do
      expect(to_rack_response).to match_array([
        anything,
        a_hash_including("content-type" => "text/plain"),
        anything
      ])
    end

    it "returns the content length of the body" do
      expect(to_rack_response).to match_array([
        anything,
        a_hash_including("content-length" => "23"),
        anything
      ])
    end

    it "explains that authentication is required" do
      expect(to_rack_response).to match_array([anything, anything, ["Authentication required"]])
    end

    context "when the endpoint provides a challenge" do
      let(:challenge) { 'Bearer realm="liberty"' }

      before { allow(endpoint).to receive(:www_authenticate_header).and_return(challenge) }

      it "includes a www-authenticate header" do
        expect(to_rack_response).to match_array([
          anything,
          a_hash_including("www-authenticate" => challenge),
          anything
        ])
      end
    end

    context "when the endpoint does NOT provide a challenge" do
      it "does not include a www-authenticate header" do
        expect(to_rack_response).to match_array([
          anything,
          hash_excluding({"www-authenticate" => anything}),
          anything
        ])
      end
    end

    context "when the request is a HEAD request" do
      let(:request) { instance_double(Liberty::Adapters::Request, head?: true) }

      it "returns an empty body" do
        expect(to_rack_response).to match_array([anything, anything, []])
      end

      it "still reports the content length of the body" do
        expect(to_rack_response).to match_array([
          anything,
          a_hash_including("content-length" => "23"),
          anything
        ])
      end
    end
  end
end
