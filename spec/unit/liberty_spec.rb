# frozen_string_literal: true

RSpec.describe Liberty do
  describe "#rack_app" do
    subject(:rack_app) { Liberty.rack_app }

    it "returns a Rack::Builder" do
      expect(rack_app).to be_a_kind_of(Rack::Builder)
    end

    it "returns the same object every time" do
      expect(rack_app).to be(Liberty.rack_app)
    end
  end

  describe "#add_endpoint" do
    subject(:add_endpoint) { Liberty.add_endpoint(**params) }

    let(:params) { {verb: :verb, path: :path, endpoint_class: :endpoint_class} }

    before do
      allow(Liberty.router).to receive(:verb)
      add_endpoint
    end

    it "delegates to the router" do
      expect(Liberty.router).to have_received(:verb).with(:path, to: a_kind_of(Liberty::Application))
    end
  end

  describe "#router" do
    subject(:router) { Liberty.router }

    it "returns a Liberty::router" do
      expect(router).to be_a_kind_of(Liberty::Router)
    end

    it "returns the same object every time" do
      expect(router).to be(Liberty.router)
    end
  end
end
