# frozen_string_literal: true

require "liberty/router"
require "rack/mock"
require "json"

RSpec.describe Liberty::Router do
  shared_examples "a registered route" do |options|
    context "when the path is the root" do
      it "calls the endpoint with empty params" do
        router = described_class.new
        endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
        router.public_send(options[:method], "/", to: endpoint)

        response = Rack::MockRequest.new(router).public_send(options[:method], "/")

        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context "when the path is static" do
      it "calls the endpoint with empty params" do
        router = described_class.new
        endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
        router.public_send(options[:method], "/static", to: endpoint)

        response = Rack::MockRequest.new(router).public_send(options[:method], "/static")

        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context "when the path is dynamic" do
      context "and the path has a dynamic segment" do
        it "calls the endpoint with the router params" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.public_send(options[:method], "/dynamic/:var1", to: endpoint)

          response = Rack::MockRequest.new(router).public_send(options[:method], "/dynamic/123")

          expect(JSON.parse(response.body)).to eq({"var1" => "123"})
        end
      end

      context "and the path has multiple dynamic segments" do
        it "calls the endpoint with the router params" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.public_send(options[:method], "/dynamic/:var1/segment/:var2", to: endpoint)

          response = Rack::MockRequest.new(router).public_send(options[:method], "/dynamic/123/segment/456")

          expect(JSON.parse(response.body)).to eq({"var1" => "123", "var2" => "456"})
        end
      end
    end

    context "when multiple dynamic paths are registered" do
      it "calls the endpoint with the router params" do
        router = described_class.new
        endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
        router.public_send(options[:method], "/dynamic/:var1/segment_one", to: endpoint)
        router.public_send(options[:method], "/dynamic/:var1/segment_two", to: endpoint)

        response = Rack::MockRequest.new(router).public_send(options[:method], "/dynamic/123/segment_two")

        expect(JSON.parse(response.body)).to eq({"var1" => "123"})
      end
    end

    context "when there is no route for the requested url" do
      context "and the registered path is static" do
        it "responds with 404" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.public_send(options[:method], "/static", to: endpoint)

          response = Rack::MockRequest.new(router).public_send(options[:method], "/not_registered")

          expect(response.status).to eq(404)
        end
      end

      context "and the registered path is dynamic" do
        it "responds with 404" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.public_send(options[:method], "/dynamic/:var1", to: endpoint)

          response = Rack::MockRequest.new(router).public_send(options[:method], "/not_registered")

          expect(response.status).to eq(404)
        end
      end
    end

    context "when the route does not match the dynamic segment" do
      it "responds with 404" do
        router = described_class.new
        endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
        router.public_send(options[:method], "/dynamic/:var1_:var2/segment2", to: endpoint)

        response = Rack::MockRequest.new(router).public_send(options[:method], "/dynamic/1")

        expect(response.status).to eq(404)
      end
    end

    context "when the route is a partial match" do
      it "responds with 404" do
        router = described_class.new
        endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
        router.public_send(options[:method], "/dynamic/:var1/segment2", to: endpoint)

        response = Rack::MockRequest.new(router).public_send(options[:method], "/dynamic/1/invalid1/invalid2")

        expect(response.status).to eq(404)
      end
    end
  end

  describe "#get" do
    it_behaves_like "a registered route", method: :get

    context "when the request is a HEAD request" do
      context "and the url matches a registered GET route" do
        it "calls the endpoint" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.get("/static", to: endpoint)

          response = Rack::MockRequest.new(router).head("/static")

          expect(response.status).to eq(200)
        end
      end

      context "and there is no route for the requested url" do
        it "responds with 404" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.get("/static", to: endpoint)

          response = Rack::MockRequest.new(router).head("/not_registered")

          expect(response.status).to eq(404)
        end

        it "responds with an empty body" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.get("/static", to: endpoint)

          response = Rack::MockRequest.new(router).head("/not_registered")

          expect(response.body).to eq("")
        end

        it "reports the content length of the GET body" do
          router = described_class.new
          endpoint = ->(env) { [200, {"content-type" => "text/plain"}, [env["router.params"].to_json]] }
          router.get("/static", to: endpoint)

          response = Rack::MockRequest.new(router).head("/not_registered")

          expect(response.headers["content-length"]).to eq("9")
        end
      end
    end
  end

  describe "#post" do
    it_behaves_like "a registered route", method: :post
  end

  describe "#put" do
    it_behaves_like "a registered route", method: :put
  end

  describe "#patch" do
    it_behaves_like "a registered route", method: :patch
  end

  describe "#delete" do
    it_behaves_like "a registered route", method: :delete
  end

  describe "#print" do
    it "delegates to the printer" do
      router = described_class.new
      endpoint = Class.new { def self.to_s = "Endpoint" }
      router.get("/static", to: endpoint)
      stdout = StringIO.new

      router.print(stdout)

      expect(stdout.string).to include("GET /static")
      expect(stdout.string).to include("=> Endpoint")
    end
  end
end
