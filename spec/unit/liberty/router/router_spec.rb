# frozen_string_literal: true

require "liberty/router"
require "rack/mock"
require "json"

RSpec.describe Liberty::Router do
  subject(:router) { described_class.new }

  let(:app) { Rack::MockRequest.new(router) }
  let(:endpoint) { ->(env) { [status, headers, [env["router.params"].to_json]] } }
  let(:status) { 200 }
  let(:headers) { {"Content-Type" => "txt/plain"} }

  shared_examples "a registered route" do |options|
    subject(:register_route) { router.public_send(options[:method], registered_path, to: endpoint) }

    let(:response) { app.public_send(options[:method], request_url) }
    let(:endpoint_response) { JSON.parse(response.body) }

    before do
      register_route
    end

    context "when the path is the root" do
      let(:registered_path) { "/" }
      let(:request_url) { registered_path }

      it "calls the endpoint with empty params" do
        expect(endpoint_response).to eq({})
      end
    end

    context "when the path is static" do
      let(:registered_path) { "/static" }
      let(:request_url) { registered_path }

      it "calls the endpoint with empty params" do
        expect(endpoint_response).to eq({})
      end
    end

    context "when the path is dynamic" do
      context "and the path has a dynamic segment" do
        let(:registered_path) { "/dynamic/:var1" }
        let(:request_url) { "/dynamic/123" }
        let(:response_body) { {"var1" => "123"} }

        it "calls the endpoint with the router params" do
          expect(endpoint_response).to eq(response_body)
        end
      end

      context "and the path has multiple dynamic segments" do
        let(:registered_path) { "/dynamic/:var1/segment/:var2" }
        let(:request_url) { "/dynamic/123/segment/456" }
        let(:response_body) { {"var1" => "123", "var2" => "456"} }

        it "calls the endpoint with the router params" do
          expect(endpoint_response).to eq(response_body)
        end
      end
    end

    context "when multiple dynamic paths are registered" do
      let(:registered_path) { "/dynamic/:var1/segment_one" }
      let(:registered_path_2) { "/dynamic/:var1/segment_two" }
      let(:request_url) { "/dynamic/123/segment_two" }
      let(:response_body) { {"var1" => "123"} }

      before do
        router.public_send(options[:method], registered_path_2, to: endpoint)
      end

      it "calls the endpoint with the router params" do
        expect(endpoint_response).to eq(response_body)
      end
    end

    context "when there is no route for the requested url" do
      let(:request_url) { "/not_registered" }

      context "and the registered path is static" do
        let(:registered_path) { "/static" }

        it "responds with 404" do
          expect(response.status).to eq(404)
        end
      end

      context "and the registered path is dynamic" do
        let(:registered_path) { "/dynamic/:var1" }

        it "responds with 404" do
          expect(response.status).to eq(404)
        end
      end
    end

    context "when the route does not match the dynamic segment" do
      let(:registered_path) { "/dynamic/:var1_:var2/segment2" }
      let(:request_url) { "/dynamic/1" }

      it "responds with 404" do
        expect(response.status).to eq(404)
      end
    end

    context "when the route is a partial match" do
      let(:registered_path) { "/dynamic/:var1/segment2" }
      let(:request_url) { "/dynamic/1/invalid1/invalid2" }

      it "responds with 404" do
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#get" do
    it_behaves_like "a registered route", method: :get
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
    subject(:print) { router.print }
    let(:printer) { instance_double(Liberty::Router::Printer, print: true) }

    before do
      allow(Liberty::Router::Printer).to receive(:new).and_return(printer)
      print
    end

    it "delegates to the printer" do
      expect(printer).to have_received(:print)
    end
  end
end
