# frozen_string_literal: true

RSpec.describe Liberty::Endpoint do
  let(:endpoint_class) { Class.new(described_class) }

  describe ".responds_to" do
    subject(:responds_to) { endpoint_class.responds_to(verb, path) }

    let(:verb) { :get }
    let(:path) { "/" }

    before do
      allow(Liberty).to receive(:add_endpoint)
      responds_to
    end

    it "registers endpoint with server" do
      expect(Liberty)
        .to have_received(:add_endpoint)
        .with(
          verb: verb,
          path: path,
          endpoint_class: endpoint_class
        )
    end
  end

  describe "#inject" do
    let(:endpoint) { endpoint_class.new }
    let(:request) { instance_double("request") }
    let(:principal) { instance_double("principal") }

    context "when given a principal" do
      before { endpoint.inject(request: request, principal: principal) }

      it "sets the request" do
        expect(endpoint.request).to eq(request)
      end

      it "sets the principal" do
        expect(endpoint.principal).to eq(principal)
      end
    end

    context "when NOT given a principal" do
      before { endpoint.inject(request: request) }

      it "sets the request" do
        expect(endpoint.request).to eq(request)
      end

      it "leaves the principal nil" do
        expect(endpoint.principal).to be_nil
      end
    end
  end

  describe "#params" do
    subject(:params) { endpoint.params }

    let(:endpoint_class) { Class.new(described_class) }
    let(:endpoint) { endpoint_class.new }
    let(:request) { instance_double("request", params: params) }
    let(:params) { {freedom: "liberty"} }

    before { endpoint.inject(request: request) }

    it "adds a convenience #params method to endpoint objects" do
      expect(endpoint.params).to eq(params)
    end
  end

  describe "#preferred_media_type" do
    subject(:params) { endpoint.preferred_media_type }

    let(:endpoint_class) { Class.new(described_class) }
    let(:endpoint) { endpoint_class.new }
    let(:request) { instance_double("request", headers: headers) }
    let(:headers) { {preferred_media_type: "application/json"} }

    before { endpoint.inject(request: request) }

    it "adds a convenience #preferred_media_type method to endpoint objects" do
      expect(endpoint.preferred_media_type).to eq("application/json")
    end
  end

  describe "#authenticated?" do
    subject(:authenticated?) { endpoint.authenticated? }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #authenticated?" do
      let(:endpoint_class) { Class.new(described_class) { def authenticated? = true } }

      it "returns the result" do
        expect(authenticated?).to be(true)
      end
    end

    context "when the endpoint class does NOT implement #authenticated?" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns false" do
        expect(authenticated?).to be(false)
      end
    end
  end

  describe "#www_authenticate_header" do
    subject(:www_authenticate_header) { endpoint.www_authenticate_header }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #www_authenticate_header" do
      let(:endpoint_class) { Class.new(described_class) { def www_authenticate_header = "Bearer" } }

      it "returns the challenge" do
        expect(www_authenticate_header).to eq("Bearer")
      end
    end

    context "when the endpoint class does NOT implement #www_authenticate_header" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(www_authenticate_header).to be_nil
      end
    end
  end

  describe "#authorized?" do
    subject(:authorized?) { endpoint.authorized? }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #authorized?" do
      let(:endpoint_class) { Class.new(described_class) { def authorized? = true } }

      it "returns the result" do
        expect(authorized?).to be(true)
      end
    end

    context "when the endpoint class does NOT implement #authorized?" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns false" do
        expect(authorized?).to be(false)
      end
    end
  end

  describe "#status" do
    subject(:status) { endpoint.status }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implement #status" do
      let(:endpoint_class) { Class.new(described_class) { def status = 420 } }

      it "returns the status" do
        expect(status).to eq(420)
      end
    end

    context "when the endpoint class does NOT implement #status" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns the default status" do
        expect(status).to eq(200)
      end
    end
  end

  describe "#headers" do
    subject(:headers) { endpoint.headers }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implement #headers" do
      let(:endpoint_class) { Class.new(described_class) { def headers = {"Header" => "value"} } }

      it "includes the headers" do
        expect(headers).to eq("Header" => "value")
      end
    end

    context "when the endpoint class does NOT implement #headers" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(headers).to be_nil
      end
    end
  end

  describe "#json" do
    subject(:json) { endpoint.json }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #json" do
      let(:endpoint_class) { Class.new(described_class) { def json = {key: "value"} } }

      it "includes the json" do
        expect(json).to eq(key: "value")
      end
    end

    context "when the endpoint class does NOT implement #json" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(json).to be_nil
      end
    end
  end

  describe "#html" do
    subject(:html) { endpoint.html }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #html" do
      let(:endpoint_class) { Class.new(described_class) { def html = "<html><body>FREEDOM!</body></html>" } }

      it "includes the html" do
        expect(html).to eq("<html><body>FREEDOM!</body></html>")
      end
    end

    context "when the endpoint class does NOT implement #html" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(html).to be_nil
      end
    end
  end

  describe "#text" do
    subject(:text) { endpoint.text }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #text" do
      let(:endpoint_class) { Class.new(described_class) { def text = "FREEDOM!" } }

      it "includes the text" do
        expect(text).to eq("FREEDOM!")
      end
    end

    context "when the endpoint class does NOT implement #text" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(text).to be_nil
      end
    end
  end

  describe "#body" do
    subject(:body) { endpoint.body }

    let(:endpoint) { endpoint_class.new }

    context "when the endpoint class implements #body" do
      let(:endpoint_class) { Class.new(described_class) { def body = "FREEDOM!" } }

      it "includes the body" do
        expect(body).to eq("FREEDOM!")
      end
    end

    context "when the endpoint class does NOT implement #body" do
      let(:endpoint_class) { Class.new(described_class) }

      it "returns nil" do
        expect(body).to be_nil
      end
    end
  end
end
