RSpec.describe Liberty::Application do
  subject(:adapter) { described_class.new(endpoint_class: endpoint_class) }

  let(:endpoint_class) { class_double(Liberty::Endpoint) }

  describe "#call" do
    subject(:call) { adapter.call(env) }

    let(:env) { instance_double("env") }
    let(:request_adapter) { instance_double(Liberty::Adapters::Request) }
    let(:response_adapter) { instance_double(Liberty::Adapters::Response, to_rack_response: rack_response) }
    let(:endpoint) { instance_double(Liberty::Endpoint, inject: true, status: 200, json: {}) }
    let(:rack_response) { ["status", "headers", ["body"]] }

    before do
      allow(Liberty::Adapters::Request).to receive(:new).and_return(request_adapter)
      allow(Liberty::Adapters::Response).to receive(:new).and_return(response_adapter)
      allow(endpoint_class).to receive(:new).and_return(endpoint)

      call
    end

    it "wraps the env in a Request object" do
      expect(Liberty::Adapters::Request).to have_received(:new).with(env)
    end

    it "injects the request into the endpoint" do
      expect(endpoint).to have_received(:inject).with(request: request_adapter)
    end

    it "wraps the endpoint in a Response adapter" do
      expect(Liberty::Adapters::Response).to have_received(:new).with(endpoint)
    end

    it "returns a rack response" do
      expect(call).to eq(rack_response)
    end
  end
end
