# frozen_string_literal: true

RSpec.describe Liberty do
  let(:request) { Rack::MockRequest.new(app) }
  let(:app) { Liberty.rack_app }

  context "user defined endpoint" do
    let(:uri) { "/freedom?value=1" }
    let(:response) { request.get(uri, options) }
    let(:options) { {"HTTP_ACCEPT" => "application/json"} }
    let!(:endpoint_class) do
      Class.new(Liberty::Endpoint) do
        responds_to :get, "/freedom"

        def status
          201
        end

        def json
          {message: "Freedom!", value: params[:value].to_i}
        end

        def headers
          {"x-custom-header" => "custom value"}
        end
      end
    end

    it "responds with the user provided data" do
      expect(response.body).to eq({message: "Freedom!", value: 1}.to_json)
      expect(response.status).to eq(201)
      expect(response.headers["X-Custom-Header"]).to eq("custom value")
    end
  end

  context "HEAD request" do
    let(:app) { Rack::Lint.new(Liberty.rack_app) }
    let(:uri) { "/freedom?value=1" }
    let(:response) { request.head(uri, options) }
    let(:options) { {"HTTP_ACCEPT" => "application/json"} }
    let(:get_body) { {message: "Freedom!", value: 1}.to_json }
    let!(:endpoint_class) do
      Class.new(Liberty::Endpoint) do
        responds_to :get, "/freedom"

        def status
          201
        end

        def json
          {message: "Freedom!", value: params[:value].to_i}
        end

        def headers
          {"x-custom-header" => "custom value"}
        end
      end
    end

    it "responds with the GET status and headers, but an empty body" do
      expect(response.body).to eq("")
      expect(response.status).to eq(201)
      expect(response.headers["content-length"]).to eq(get_body.bytesize.to_s)
      expect(response.headers["content-type"]).to eq("application/json")
      expect(response.headers["x-custom-header"]).to eq("custom value")
    end

    context "when there is no route for the requested url" do
      let(:uri) { "/nowhere" }

      it "responds with 404 and an empty body" do
        expect(response.status).to eq(404)
        expect(response.body).to eq("")
        expect(response.headers["content-length"]).to eq("9")
      end
    end
  end

  context "when CORS is configured" do
    before do
      Liberty::CORS.config do |config|
        config.headers = {
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Methods" => "GET, OPTIONS"
        }
      end
    end

    after do
      Liberty::CORS.config { |config| config.headers = {} }
    end

    context "and there is a CORS request" do
      let(:uri) { "/freedom" }
      let(:response) { request.options(uri, options) }
      let(:options) { {"HTTP_ACCEPT" => "application/json"} }
      let!(:endpoint_class) do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom"
        end
      end

      it "responds with a CORS response" do
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      end
    end

    context "and there is a non-CORS request" do
      let(:uri) { "/freedom" }
      let(:response) { request.get(uri, options) }
      let(:options) { {"HTTP_ACCEPT" => "application/json"} }
      let!(:endpoint_class) do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom"
        end
      end

      it "includes the Access-Control-Allow-Origin header" do
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      end
    end
  end

  context "when CORS is NOT configured" do
    before do
      Liberty::CORS.config { |config| config.headers = {} }
    end

    context "and there is a CORS request" do
      let(:uri) { "/freedom" }
      let(:response) { request.options(uri, options) }
      let(:options) { {"HTTP_ACCEPT" => "application/json"} }
      let!(:endpoint_class) do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom"
        end
      end

      it "responds with a 404 response" do
        expect(response.status).to eq(404)
      end
    end

    context "and there is a non-CORS request" do
      let(:uri) { "/freedom" }
      let(:response) { request.get(uri, options) }
      let(:options) { {"HTTP_ACCEPT" => "application/json"} }
      let!(:endpoint_class) do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom"
        end
      end

      it "does NOT include an Access-Control-Allow-Origin header" do
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
      end
    end
  end
end
