# frozen_string_literal: true

RSpec.describe Liberty::Adapters::Request do
  describe "#headers" do
    context "when the env is nil" do
      it "returns an empty hash" do
        request = described_class.new(nil)

        headers = request.headers

        expect(headers).to eq({})
      end
    end

    context "when the env is NOT nil" do
      it "delegates to Rack::Request to get the accept_media_types header" do
        env = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/json,text/html")
        request = described_class.new(env)

        headers = request.headers

        expect(headers[:accept_media_types]).to eq(Rack::Request.new(env).accept_media_types)
      end

      it "includes the accept_media_types header" do
        env = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/json,text/html")
        request = described_class.new(env)

        headers = request.headers

        expect(headers[:accept_media_types]).to eq(["application/json", "text/html"])
      end

      it "includes the preferred media type header" do
        env = Rack::MockRequest.env_for("/", "HTTP_ACCEPT" => "application/json,text/html")
        request = described_class.new(env)

        headers = request.headers

        expect(headers[:preferred_media_type]).to eq("application/json")
      end

      context "and the request has an Authorization header" do
        it "includes the authorization header" do
          env = Rack::MockRequest.env_for("/", "HTTP_AUTHORIZATION" => "Bearer token")
          request = described_class.new(env)

          headers = request.headers

          expect(headers).to include(authorization: "Bearer token")
        end
      end

      context "and the request does NOT have an Authorization header" do
        it "includes a nil authorization header" do
          env = Rack::MockRequest.env_for("/")
          request = described_class.new(env)

          headers = request.headers

          expect(headers).to include(authorization: nil)
        end
      end
    end
  end

  describe "#head?" do
    context "when the env is nil" do
      it "returns false" do
        request = described_class.new(nil)

        head = request.head?

        expect(head).to be(false)
      end
    end

    context "when the request method is HEAD" do
      it "returns true" do
        request = described_class.new(Rack::MockRequest.env_for("/", method: "HEAD"))

        head = request.head?

        expect(head).to be(true)
      end
    end

    context "when the request method is NOT HEAD" do
      it "returns false" do
        request = described_class.new(Rack::MockRequest.env_for("/", method: "GET"))

        head = request.head?

        expect(head).to be(false)
      end
    end
  end

  describe "#params" do
    context "when the env is nil" do
      it "returns an empty hash" do
        request = described_class.new(nil)

        params = request.params

        expect(params).to eq({})
      end
    end

    context "when the env is NOT nil" do
      it "delegates to Rack::Request to get form params" do
        env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json", :input => {body_param: "body_value"}.to_json)
        env["router.params"] = {url_param: "url_value"}
        request = described_class.new(env)

        params = request.params

        expect(params[:form_param]).to eq(Rack::Request.new(env).params["form_param"])
      end

      it "parses params out of the env form data" do
        env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json", :input => {body_param: "body_value"}.to_json)
        env["router.params"] = {url_param: "url_value"}
        request = described_class.new(env)

        params = request.params

        expect(params).to include(form_param: "form_value")
      end

      it "parses params out of the env body" do
        env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json", :input => {body_param: "body_value"}.to_json)
        env["router.params"] = {url_param: "url_value"}
        request = described_class.new(env)

        params = request.params

        expect(params).to include(body_param: "body_value")
      end

      it "parses params out of the env query string" do
        env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json", :input => {body_param: "body_value"}.to_json)
        env["router.params"] = {url_param: "url_value"}
        request = described_class.new(env)

        params = request.params

        expect(params).to include(url_param: "url_value")
      end

      context "when the body is rewindable" do
        it "rewinds the body after reading it" do
          env = Rack::MockRequest.env_for("/", :method => "POST", "CONTENT_TYPE" => "application/json", :input => {body_param: "body_value"}.to_json)
          request = described_class.new(env)

          request.params

          expect(env["rack.input"].read).to eq({body_param: "body_value"}.to_json)
        end
      end

      context "when the body is NOT rewindable" do
        it "does not attempt to rewind the body" do
          unrewindable_body = Class.new do
            def initialize(content) = @content = content

            def read = @content
          end
          env = Rack::MockRequest.env_for("/", :method => "POST", "CONTENT_TYPE" => "application/json")
          env["rack.input"] = unrewindable_body.new({body_param: "body_value"}.to_json)
          request = described_class.new(env)

          params = request.params

          expect(params).to include(body_param: "body_value")
        end
      end

      context "when there is no body" do
        it "does not include body params" do
          env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json")
          env["router.params"] = {url_param: "url_value"}
          env.delete("rack.input")
          request = described_class.new(env)

          params = request.params

          expect(params).not_to include(:body_param)
        end

        it "still includes form and query string params" do
          env = Rack::MockRequest.env_for("/?form_param=form_value", :method => "POST", "CONTENT_TYPE" => "application/json")
          env["router.params"] = {url_param: "url_value"}
          env.delete("rack.input")
          request = described_class.new(env)

          params = request.params

          expect(params).to eq(form_param: "form_value", url_param: "url_value")
        end
      end
    end
  end
end
