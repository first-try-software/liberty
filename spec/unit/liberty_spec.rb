# frozen_string_literal: true

RSpec.describe Liberty do
  describe "#rack_app" do
    it "returns a Rack::Builder" do
      rack_app = Liberty.rack_app

      expect(rack_app).to be_a_kind_of(Rack::Builder)
    end

    it "returns the same object every time" do
      rack_app = Liberty.rack_app

      expect(rack_app).to be(Liberty.rack_app)
    end
  end

  describe "#add_endpoint" do
    it "builds an application from the endpoint class and its authenticator" do
      endpoint_class = Class.new(Liberty::Endpoint) do
        def text = "built for #{principal}"
      end
      challenge_class = Class.new(Liberty::Endpoint) do
        def status = 418
      end
      authenticator_class = Class.new(Liberty::Authenticator) do
        def principal
          "Alan" if request.headers[:authorization] == "Bearer secret"
        end

        define_method(:challenge_endpoint_class) { challenge_class }
      end
      Liberty.add_endpoint(verb: :get, path: "/add_endpoint/built", endpoint_class: endpoint_class, authenticator_class: authenticator_class)

      admitted_status, _headers, admitted_body = Liberty.router.call(Rack::MockRequest.env_for("/add_endpoint/built", "HTTP_AUTHORIZATION" => "Bearer secret"))
      challenged_status, _headers, _body = Liberty.router.call(Rack::MockRequest.env_for("/add_endpoint/built"))

      expect(admitted_status).to eq(200)
      expect(admitted_body.join).to eq("built for Alan")
      expect(challenged_status).to eq(418)
    end

    it "delegates to the router" do
      endpoint_class = Class.new(Liberty::Endpoint) do
        def text = "routed"
      end
      Liberty.add_endpoint(verb: :get, path: "/add_endpoint/routed", endpoint_class: endpoint_class, authenticator_class: Liberty::Authenticators::Public)

      status, _headers, body = Liberty.router.call(Rack::MockRequest.env_for("/add_endpoint/routed"))

      expect(status).to eq(200)
      expect(body.join).to eq("routed")
    end
  end

  describe "#router" do
    it "returns a Liberty::router" do
      router = Liberty.router

      expect(router).to be_a_kind_of(Liberty::Router)
    end

    it "returns the same object every time" do
      router = Liberty.router

      expect(router).to be(Liberty.router)
    end
  end
end
