# frozen_string_literal: true

RSpec.describe Liberty::Adapters::Response do
  describe "#to_rack_response" do
    context "when the request is a HEAD request" do
      it "returns an empty body" do
        endpoint = Class.new(Liberty::Endpoint) { def json = {key: "value"} }.new
        endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/", method: "HEAD")))

        _status, _headers, body = described_class.new(endpoint).to_rack_response

        expect(body).to eq([])
      end

      it "still reports the content length of the content" do
        endpoint = Class.new(Liberty::Endpoint) { def json = {key: "value"} }.new
        endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/", method: "HEAD")))

        _status, headers, _body = described_class.new(endpoint).to_rack_response

        expect(headers["content-length"]).to eq({key: "value"}.to_json.bytesize.to_s)
      end

      it "still reports the content type of the content" do
        endpoint = Class.new(Liberty::Endpoint) { def json = {key: "value"} }.new
        endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/", method: "HEAD")))

        _status, headers, _body = described_class.new(endpoint).to_rack_response

        expect(headers["content-type"]).to eq("application/json")
      end
    end

    context "when endpoint returns a status" do
      it "returns the provided status" do
        endpoint = Class.new(Liberty::Endpoint) { def status = 418 }.new
        endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

        status, _headers, _body = described_class.new(endpoint).to_rack_response

        expect(status).to eq(418)
      end
    end

    context "when the endpoint does NOT return headers" do
      context "and the content type is JSON" do
        it "adds an application/json content type to headers" do
          endpoint = Class.new(Liberty::Endpoint) { def json = {} }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-type"]).to eq("application/json")
        end
      end

      context "and the content type is HTML" do
        it "adds an text/html content type to headers" do
          endpoint = Class.new(Liberty::Endpoint) { def html = "<html></html>" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-type"]).to eq("text/html")
        end
      end

      context "and the content type is TEXT" do
        it "adds an text/plain content type to headers" do
          endpoint = Class.new(Liberty::Endpoint) { def text = "UN TEXTO" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-type"]).to eq("text/plain")
        end
      end

      context "and the content type is NOT specified" do
        it "does not add a content type header" do
          endpoint = Class.new(Liberty::Endpoint) { def body = "0x0123" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers).not_to have_key("content-type")
        end
      end
    end

    context "when the endpoint returns headers" do
      context "and the headers are custom headers" do
        it "returns the provided headers" do
          endpoint = Class.new(Liberty::Endpoint) { def headers = {"X-Test-Header" => "Look Ma! I did a header!"} }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers).to include("X-Test-Header" => "Look Ma! I did a header!")
        end
      end

      context "and the headers do NOT include content type" do
        it "adds a content type header" do
          endpoint = Class.new(Liberty::Endpoint) do
            def headers = {}

            def text = ""
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers).to have_key("content-type")
        end
      end

      context "and the headers include content type" do
        it "honors the user-provided content type" do
          endpoint = Class.new(Liberty::Endpoint) do
            def headers = {"content-type" => "image/png"}

            def text = ""
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-type"]).to eq("image/png")
        end
      end

      context "and the headers do NOT include content length" do
        it "adds a content length header" do
          endpoint = Class.new(Liberty::Endpoint) do
            def headers = {}

            def text = "Freedøm!"
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-length"]).to eq("9")
        end
      end

      context "and the headers include content length" do
        it "honors the user-provided content length" do
          endpoint = Class.new(Liberty::Endpoint) do
            def headers = {"content-length" => "42"}

            def text = ""
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, headers, _body = described_class.new(endpoint).to_rack_response

          expect(headers["content-length"]).to eq("42")
        end
      end
    end

    context "when there is NOT content" do
      it "contains an empty string in the body" do
        endpoint = Class.new(Liberty::Endpoint) { def body = "" }.new
        endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

        _status, _headers, body = described_class.new(endpoint).to_rack_response

        expect(body).to eq([""])
      end
    end

    context "when there is content" do
      context "and the content only includes JSON" do
        context "and the JSON contains a valid JSON string" do
          it "returns the valid JSON string" do
            endpoint = Class.new(Liberty::Endpoint) { def json = {key: "value"}.to_json }.new
            endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

            _status, _headers, body = described_class.new(endpoint).to_rack_response

            expect(body).to eq([{key: "value"}.to_json])
          end
        end

        context "and the JSON is NOT a valid JSON string" do
          it "returns a valid JSON string" do
            endpoint = Class.new(Liberty::Endpoint) { def json = {key: "value"} }.new
            endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

            _status, _headers, body = described_class.new(endpoint).to_rack_response

            expect(body).to eq([{key: "value"}.to_json])
          end
        end
      end

      context "and the content only includes HTML" do
        it "returns the HTML" do
          endpoint = Class.new(Liberty::Endpoint) { def html = "<html></html>" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq(["<html></html>"])
        end
      end

      context "and the content only includes text" do
        it "returns the text" do
          endpoint = Class.new(Liberty::Endpoint) { def text = "text" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq(["text"])
        end
      end

      context "and the content only includes a body" do
        it "returns the content" do
          endpoint = Class.new(Liberty::Endpoint) { def body = "body" }.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq(["body"])
        end
      end

      context "and the content includes JSON and HTML" do
        it "returns the JSON" do
          endpoint = Class.new(Liberty::Endpoint) do
            def json = {key: "value"}.to_json

            def html = "<html></html>"
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq([{key: "value"}.to_json])
        end
      end

      context "and the content includes HTML and text" do
        it "returns the HTML" do
          endpoint = Class.new(Liberty::Endpoint) do
            def html = "<html></html>"

            def text = "text"
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq(["<html></html>"])
        end
      end

      context "and the content includes text and body" do
        it "returns the text" do
          endpoint = Class.new(Liberty::Endpoint) do
            def text = "text"

            def body = "body"
          end.new
          endpoint.inject(request: Liberty::Adapters::Request.new(Rack::MockRequest.env_for("/")))

          _status, _headers, body = described_class.new(endpoint).to_rack_response

          expect(body).to eq(["text"])
        end
      end
    end
  end
end
