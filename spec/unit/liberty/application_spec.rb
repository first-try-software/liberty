# frozen_string_literal: true

RSpec.describe Liberty::Application do
  subject(:adapter) { described_class.new(endpoint_class: endpoint_class, authenticator: authenticator) }

  let(:endpoint_class) { class_double(Liberty::Endpoint, new: endpoint) }
  let(:endpoint) { instance_double(Liberty::Endpoint, inject: true) }
  let(:challenge_class) { class_double(Liberty::Endpoint, new: challenge) }
  let(:challenge) { instance_double(Liberty::Endpoint, inject: true) }
  let(:authenticator) { class_double(Liberty::Authenticators::Public, principal: principal, challenge: challenge_class) }
  let(:principal) { instance_double("principal") }

  describe "#call" do
    subject(:call) { adapter.call(env) }

    let(:env) { instance_double("env") }
    let(:request_adapter) { instance_double(Liberty::Adapters::Request) }
    let(:response_adapter) { instance_double(Liberty::Adapters::Response, to_rack_response: rack_response) }
    let(:rack_response) { ["status", "headers", ["body"]] }

    before do
      allow(Liberty::Adapters::Request).to receive(:new).and_return(request_adapter)
      allow(Liberty::Adapters::Response).to receive(:new).and_return(response_adapter)

      call
    end

    it "wraps the env in a Request object" do
      expect(Liberty::Adapters::Request).to have_received(:new).with(env)
    end

    it "asks the authenticator who the request is from" do
      expect(authenticator).to have_received(:principal).with(request_adapter)
    end

    it "returns a rack response" do
      expect(call).to eq(rack_response)
    end

    context "when the authenticator finds a principal" do
      it "injects the request and principal into the endpoint" do
        expect(endpoint).to have_received(:inject).with(request: request_adapter, principal: principal)
      end

      it "wraps the endpoint in a Response adapter" do
        expect(Liberty::Adapters::Response).to have_received(:new).with(endpoint)
      end

      it "does NOT build the challenge" do
        expect(challenge_class).not_to have_received(:new)
      end
    end

    context "when the authenticator finds no principal" do
      let(:principal) { nil }

      context "and it challenges" do
        it "injects the request and a nil principal into the challenge" do
          expect(challenge).to have_received(:inject).with(request: request_adapter, principal: nil)
        end

        it "wraps the challenge in a Response adapter" do
          expect(Liberty::Adapters::Response).to have_received(:new).with(challenge)
        end

        it "does NOT build the endpoint" do
          expect(endpoint_class).not_to have_received(:new)
        end
      end

      context "and it does NOT challenge" do
        let(:challenge_class) { nil }

        it "injects the request and a nil principal into the endpoint" do
          expect(endpoint).to have_received(:inject).with(request: request_adapter, principal: nil)
        end

        it "wraps the endpoint in a Response adapter" do
          expect(Liberty::Adapters::Response).to have_received(:new).with(endpoint)
        end
      end
    end
  end
end
