# frozen_string_literal: true

RSpec.describe Liberty do
  context "user defined endpoint" do
    it "responds with the user provided data" do
      Class.new(Liberty::Endpoint) do
        responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public

        def status = 201

        def json = {message: "Freedom!", value: params[:value].to_i}

        def headers = {"x-custom-header" => "custom value"}
      end
      request = Rack::MockRequest.new(Liberty.rack_app)

      response = request.get("/freedom?value=1", "HTTP_ACCEPT" => "application/json")

      expect(response.status).to eq(201)
      expect(response.body).to eq({message: "Freedom!", value: 1}.to_json)
      expect(response.headers["X-Custom-Header"]).to eq("custom value")
    end
  end

  context "HEAD request" do
    it "responds with the GET status and headers, but an empty body" do
      Class.new(Liberty::Endpoint) do
        responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public

        def status = 201

        def json = {message: "Freedom!", value: params[:value].to_i}

        def headers = {"x-custom-header" => "custom value"}
      end
      request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

      response = request.head("/freedom?value=1", "HTTP_ACCEPT" => "application/json")

      expect(response.status).to eq(201)
      expect(response.body).to eq("")
      expect(response.headers["content-length"]).to eq({message: "Freedom!", value: 1}.to_json.bytesize.to_s)
      expect(response.headers["content-type"]).to eq("application/json")
      expect(response.headers["x-custom-header"]).to eq("custom value")
    end

    context "when there is no route for the requested url" do
      it "responds with 404 and an empty body" do
        request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

        response = request.head("/nowhere", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(404)
        expect(response.body).to eq("")
        expect(response.headers["content-length"]).to eq("9")
      end
    end
  end

  context "authentication by route" do
    context "with a form login" do
      it "redirects to the login page" do
        session_authenticator = Class.new(Liberty::Authenticator) do
          def principal = request.env["rack.session"][:user]

          def challenge_endpoint_class
            Class.new(Liberty::Endpoint) do
              def status = 303

              def headers = {"location" => "/login"}
            end
          end
        end
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: session_authenticator

          def html = "<h1>Welcome, #{principal[:name]}</h1>"
        end
        request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

        response = request.get("/freedom", "HTTP_ACCEPT" => "text/html", "rack.session" => {})

        expect(response.status).to eq(303)
        expect(response.headers["location"]).to eq("/login")
        expect(response.body).to eq("")
        expect(response.headers["content-length"]).to eq("0")
      end

      context "and the request is a HEAD request" do
        it "redirects with an empty body" do
          session_authenticator = Class.new(Liberty::Authenticator) do
            def principal = request.env["rack.session"][:user]

            def challenge_endpoint_class
              Class.new(Liberty::Endpoint) do
                def status = 303

                def headers = {"location" => "/login"}
              end
            end
          end
          Class.new(Liberty::Endpoint) do
            responds_to :get, "/freedom", authenticated_by: session_authenticator

            def html = "<h1>Welcome, #{principal[:name]}</h1>"
          end
          request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

          response = request.head("/freedom", "HTTP_ACCEPT" => "text/html", "rack.session" => {})

          expect(response.status).to eq(303)
          expect(response.headers["location"]).to eq("/login")
          expect(response.body).to eq("")
        end
      end

      context "and the session has a user" do
        it "responds with the page, knowing the principal" do
          session_authenticator = Class.new(Liberty::Authenticator) do
            def principal = request.env["rack.session"][:user]

            def challenge_endpoint_class
              Class.new(Liberty::Endpoint) do
                def status = 303

                def headers = {"location" => "/login"}
              end
            end
          end
          Class.new(Liberty::Endpoint) do
            responds_to :get, "/freedom", authenticated_by: session_authenticator

            def html = "<h1>Welcome, #{principal[:name]}</h1>"
          end
          request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

          response = request.get("/freedom", "HTTP_ACCEPT" => "text/html", "rack.session" => {user: {name: "Alan"}})

          expect(response.status).to eq(200)
          expect(response.headers["content-type"]).to eq("text/html")
          expect(response.body).to eq("<h1>Welcome, Alan</h1>")
        end
      end
    end

    context "with a bearer token" do
      it "responds with 401 and a www-authenticate challenge" do
        token_authenticator = Class.new(Liberty::Authenticator) do
          def principal
            {name: "Alan"} if request.headers[:authorization] == "Bearer secret"
          end

          def challenge_endpoint_class
            Class.new(Liberty::Endpoint) do
              def status = 401

              def headers = {"www-authenticate" => 'Bearer realm="liberty"'}

              def text = "Authentication required"
            end
          end
        end
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: token_authenticator

          def json = {message: "Freedom, #{principal[:name]}!"}
        end
        request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

        response = request.get("/freedom", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(401)
        expect(response.headers["www-authenticate"]).to eq('Bearer realm="liberty"')
        expect(response.headers["content-type"]).to eq("text/plain")
        expect(response.body).to eq("Authentication required")
      end

      context "and the request is a HEAD request" do
        it "responds with 401 and an empty body" do
          token_authenticator = Class.new(Liberty::Authenticator) do
            def principal
              {name: "Alan"} if request.headers[:authorization] == "Bearer secret"
            end

            def challenge_endpoint_class
              Class.new(Liberty::Endpoint) do
                def status = 401

                def headers = {"www-authenticate" => 'Bearer realm="liberty"'}

                def text = "Authentication required"
              end
            end
          end
          Class.new(Liberty::Endpoint) do
            responds_to :get, "/freedom", authenticated_by: token_authenticator

            def json = {message: "Freedom, #{principal[:name]}!"}
          end
          request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

          response = request.head("/freedom", "HTTP_ACCEPT" => "application/json")

          expect(response.status).to eq(401)
          expect(response.body).to eq("")
          expect(response.headers["content-length"]).to eq("23")
        end
      end

      context "and the request carries a valid token" do
        it "responds with the endpoint's data, knowing the principal" do
          token_authenticator = Class.new(Liberty::Authenticator) do
            def principal
              {name: "Alan"} if request.headers[:authorization] == "Bearer secret"
            end

            def challenge_endpoint_class
              Class.new(Liberty::Endpoint) do
                def status = 401

                def headers = {"www-authenticate" => 'Bearer realm="liberty"'}

                def text = "Authentication required"
              end
            end
          end
          Class.new(Liberty::Endpoint) do
            responds_to :get, "/freedom", authenticated_by: token_authenticator

            def json = {message: "Freedom, #{principal[:name]}!"}
          end
          request = Rack::MockRequest.new(Rack::Lint.new(Liberty.rack_app))

          response = request.get("/freedom", "HTTP_ACCEPT" => "application/json", "HTTP_AUTHORIZATION" => "Bearer secret")

          expect(response.status).to eq(200)
          expect(response.body).to eq({message: "Freedom, Alan!"}.to_json)
        end
      end
    end
  end

  context "when CORS is configured" do
    after { Liberty::CORS.config { |config| config.headers = {} } }

    context "and there is a CORS request" do
      it "responds with a CORS response" do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public
        end
        Liberty::CORS.config do |config|
          config.headers = {"Access-Control-Allow-Origin" => "*", "Access-Control-Allow-Methods" => "GET, OPTIONS"}
        end
        request = Rack::MockRequest.new(Liberty.rack_app)

        response = request.options("/freedom", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      end
    end

    context "and there is a non-CORS request" do
      it "includes the Access-Control-Allow-Origin header" do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public
        end
        Liberty::CORS.config do |config|
          config.headers = {"Access-Control-Allow-Origin" => "*", "Access-Control-Allow-Methods" => "GET, OPTIONS"}
        end
        request = Rack::MockRequest.new(Liberty.rack_app)

        response = request.get("/freedom", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
      end
    end
  end

  context "when CORS is NOT configured" do
    context "and there is a CORS request" do
      it "responds with a 404 response" do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public
        end
        Liberty::CORS.config { |config| config.headers = {} }
        request = Rack::MockRequest.new(Liberty.rack_app)

        response = request.options("/freedom", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(404)
      end
    end

    context "and there is a non-CORS request" do
      it "does NOT include an Access-Control-Allow-Origin header" do
        Class.new(Liberty::Endpoint) do
          responds_to :get, "/freedom", authenticated_by: Liberty::Authenticators::Public
        end
        Liberty::CORS.config { |config| config.headers = {} }
        request = Rack::MockRequest.new(Liberty.rack_app)

        response = request.get("/freedom", "HTTP_ACCEPT" => "application/json")

        expect(response.status).to eq(200)
        expect(response.body).to eq("")
        expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
      end
    end
  end
end
