# frozen_string_literal: true

RSpec.describe Liberty::Adapters::ForbiddenResponse do
  describe "#to_rack_response" do
    subject(:to_rack_response) { described_class.new(endpoint).to_rack_response }

    let(:endpoint) { Class.new(Liberty::Endpoint).new }
    let(:request) { instance_double(Liberty::Adapters::Request, head?: false) }

    before { endpoint.inject(request: request) }

    it "returns a 403 status" do
      expect(to_rack_response).to match_array([403, anything, anything])
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
        a_hash_including("content-length" => "9"),
        anything
      ])
    end

    it "explains that the request is forbidden" do
      expect(to_rack_response).to match_array([anything, anything, ["Forbidden"]])
    end

    context "when the request is a HEAD request" do
      let(:request) { instance_double(Liberty::Adapters::Request, head?: true) }

      it "returns an empty body" do
        expect(to_rack_response).to match_array([anything, anything, []])
      end

      it "still reports the content length of the body" do
        expect(to_rack_response).to match_array([
          anything,
          a_hash_including("content-length" => "9"),
          anything
        ])
      end
    end
  end
end
