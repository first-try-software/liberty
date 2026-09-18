# frozen_string_literal: true

RSpec.describe Liberty::CORS::Middleware do
  after { Liberty::CORS.config { |config| config.headers = {} } }

  describe "#call" do
    context "when CORS is NOT requested" do
      it "delegates to the app" do
        app = ->(env) { [200, {}, ["the app answered a #{env["REQUEST_METHOD"]}"]] }
        middleware = described_class.new(app)
        env = {"REQUEST_METHOD" => "GET"}

        _status, _headers, body = middleware.call(env)

        expect(body).to eq(["the app answered a GET"])
      end
    end

    context "when CORS is requested" do
      context "and CORS headers have NOT been configured" do
        it "delegates to the app" do
          app = ->(env) { [200, {}, ["the app answered a #{env["REQUEST_METHOD"]}"]] }
          middleware = described_class.new(app)
          env = {"REQUEST_METHOD" => "OPTIONS"}

          _status, _headers, body = middleware.call(env)

          expect(body).to eq(["the app answered a OPTIONS"])
        end
      end

      context "and CORS headers have been configured" do
        it "returns a CORS response" do
          app = ->(_env) { raise("the app was called") }
          middleware = described_class.new(app)
          env = {"REQUEST_METHOD" => "OPTIONS"}
          Liberty::CORS.config { |config| config.headers = {"Access-Control-Allow-Origin" => "*"} }

          status, headers, body = middleware.call(env)

          expect(status).to eq(200)
          expect(headers).to include("Access-Control-Allow-Origin" => "*")
          expect(body).to eq([])
        end
      end
    end
  end
end
