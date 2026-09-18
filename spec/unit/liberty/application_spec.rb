# frozen_string_literal: true

RSpec.describe Liberty::Application do
  describe "#call" do
    context "when the authenticator finds a principal" do
      it "responds with the endpoint, which knows the principal" do
        endpoint_class = Class.new(Liberty::Endpoint) do
          def text = "Welcome, #{principal}"
        end
        authenticator_class = Class.new(Liberty::Authenticator) do
          def principal
            "Alan" if request.headers[:authorization] == "Bearer secret"
          end

          def challenge_endpoint_class = nil
        end
        application = described_class.new(endpoint_class: endpoint_class, authenticator_class: authenticator_class)
        env = Rack::MockRequest.env_for("/", "HTTP_AUTHORIZATION" => "Bearer secret")

        status, _headers, body = application.call(env)

        expect(status).to eq(200)
        expect(body.join).to eq("Welcome, Alan")
      end
    end

    context "when the authenticator finds no principal" do
      context "and it challenges" do
        it "responds with the challenge instead" do
          endpoint_class = Class.new(Liberty::Endpoint) do
            def text = "Welcome, #{principal}"
          end
          challenge_class = Class.new(Liberty::Endpoint) do
            def status = 401

            def text = "Who goes there?"
          end
          authenticator_class = Class.new(Liberty::Authenticator) do
            def principal = nil

            define_method(:challenge_endpoint_class) { challenge_class }
          end
          application = described_class.new(endpoint_class: endpoint_class, authenticator_class: authenticator_class)
          env = Rack::MockRequest.env_for("/")

          status, _headers, body = application.call(env)

          expect(status).to eq(401)
          expect(body.join).to eq("Who goes there?")
        end

        it "never builds the endpoint" do
          endpoint_class = Class.new(Liberty::Endpoint) do
            def initialize = raise("the endpoint was built")
          end
          challenge_class = Class.new(Liberty::Endpoint) do
            def status = 401
          end
          authenticator_class = Class.new(Liberty::Authenticator) do
            def principal = nil

            define_method(:challenge_endpoint_class) { challenge_class }
          end
          application = described_class.new(endpoint_class: endpoint_class, authenticator_class: authenticator_class)
          env = Rack::MockRequest.env_for("/")

          status, _headers, _body = application.call(env)

          expect(status).to eq(401)
        end
      end

      context "and it does NOT challenge" do
        it "responds with the endpoint, which has no principal" do
          endpoint_class = Class.new(Liberty::Endpoint) do
            def text = "Welcome, #{principal || "stranger"}"
          end
          authenticator_class = Class.new(Liberty::Authenticator) do
            def principal = nil

            def challenge_endpoint_class = nil
          end
          application = described_class.new(endpoint_class: endpoint_class, authenticator_class: authenticator_class)
          env = Rack::MockRequest.env_for("/")

          status, _headers, body = application.call(env)

          expect(status).to eq(200)
          expect(body.join).to eq("Welcome, stranger")
        end
      end
    end
  end
end
