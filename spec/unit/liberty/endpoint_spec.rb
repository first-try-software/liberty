# frozen_string_literal: true

RSpec.describe Liberty::Endpoint do
  describe ".responds_to" do
    it "registers endpoint with server" do
      Class.new(described_class) do
        responds_to :get, "/responds_to/registered", authenticated_by: Liberty::Authenticators::Public

        def text = "registered"
      end

      status, _headers, body = Liberty.router.call(Rack::MockRequest.env_for("/responds_to/registered"))

      expect(status).to eq(200)
      expect(body.join).to eq("registered")
    end
  end

  describe "#inject" do
    context "when given a principal" do
      it "sets the request" do
        endpoint = Class.new(described_class).new
        request = Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/"))
        principal = Object.new

        endpoint.inject(request: request, principal: principal)

        expect(endpoint.request).to eq(request)
      end

      it "sets the principal" do
        endpoint = Class.new(described_class).new
        request = Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/"))
        principal = Object.new

        endpoint.inject(request: request, principal: principal)

        expect(endpoint.principal).to eq(principal)
      end
    end

    context "when NOT given a principal" do
      it "sets the request" do
        endpoint = Class.new(described_class).new
        request = Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/"))

        endpoint.inject(request: request)

        expect(endpoint.request).to eq(request)
      end

      it "leaves the principal nil" do
        endpoint = Class.new(described_class).new
        request = Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/"))

        endpoint.inject(request: request)

        expect(endpoint.principal).to be_nil
      end
    end
  end

  describe "#params" do
    it "adds a convenience #params method to retrieve params from the request" do
      endpoint = Class.new(described_class).new
      endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/?freedom=liberty")))

      params = endpoint.params

      expect(params).to eq(freedom: "liberty")
    end
  end

  describe "#preferred_media_type" do
    it "adds a convenience #preferred_media_type method to retrieve preferred_media_type from the request" do
      endpoint = Class.new(described_class).new
      endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/json")))

      preferred_media_type = endpoint.preferred_media_type

      expect(preferred_media_type).to eq("application/json")
    end
  end

  describe "#status" do
    context "when the endpoint class implement #status" do
      it "returns the status" do
        endpoint = Class.new(described_class) { def status = 420 }.new

        status = endpoint.status

        expect(status).to eq(420)
      end
    end

    context "when the endpoint class does NOT implement #status" do
      it "returns the default status" do
        endpoint = Class.new(described_class).new

        status = endpoint.status

        expect(status).to eq(200)
      end
    end
  end

  describe "#headers" do
    context "when the endpoint class implement #headers" do
      it "includes the headers" do
        endpoint = Class.new(described_class) { def headers = {"Header" => "value"} }.new

        headers = endpoint.headers

        expect(headers).to eq("Header" => "value")
      end
    end

    context "when the endpoint class does NOT implement #headers" do
      it "returns nil" do
        endpoint = Class.new(described_class).new

        headers = endpoint.headers

        expect(headers).to be_nil
      end
    end
  end

  describe "#json" do
    context "when the endpoint class implements #json" do
      it "includes the json" do
        endpoint = Class.new(described_class) { def json = {key: "value"} }.new

        json = endpoint.json

        expect(json).to eq(key: "value")
      end
    end

    context "when the endpoint class does NOT implement #json" do
      it "returns nil" do
        endpoint = Class.new(described_class).new

        json = endpoint.json

        expect(json).to be_nil
      end
    end
  end

  describe "#html" do
    context "when the endpoint class implements #html" do
      it "includes the html" do
        endpoint = Class.new(described_class) { def html = "<html><body>FREEDOM!</body></html>" }.new

        html = endpoint.html

        expect(html).to eq("<html><body>FREEDOM!</body></html>")
      end
    end

    context "when the endpoint class does NOT implement #html" do
      it "returns nil" do
        endpoint = Class.new(described_class).new

        html = endpoint.html

        expect(html).to be_nil
      end
    end
  end

  describe "#text" do
    context "when the endpoint class implements #text" do
      it "includes the text" do
        endpoint = Class.new(described_class) { def text = "FREEDOM!" }.new

        text = endpoint.text

        expect(text).to eq("FREEDOM!")
      end
    end

    context "when the endpoint class does NOT implement #text" do
      it "returns nil" do
        endpoint = Class.new(described_class).new

        text = endpoint.text

        expect(text).to be_nil
      end
    end
  end

  describe "#body" do
    context "when the endpoint class implements #body" do
      it "includes the body" do
        endpoint = Class.new(described_class) { def body = "FREEDOM!" }.new

        body = endpoint.body

        expect(body).to eq("FREEDOM!")
      end
    end

    context "when the endpoint class does NOT implement #body" do
      it "returns nil" do
        endpoint = Class.new(described_class).new

        body = endpoint.body

        expect(body).to be_nil
      end
    end
  end
end
