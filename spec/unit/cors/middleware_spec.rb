RSpec.describe Liberty::CORS::Middleware do
  subject(:middleware) { described_class.new(app) }

  let(:app) { instance_double("app") }

  describe "#call" do
    subject(:call) { middleware.call(env) }

    context "when CORS is NOT requested" do
      let(:env) { {"REQUEST_METHOD" => "GET"} }

      before do
        allow(app).to receive(:call)

        call
      end

      it "delegates to the app" do
        expect(app).to have_received(:call).with(env)
      end
    end

    context "when CORS is requested" do
      let(:env) { {"REQUEST_METHOD" => "OPTIONS"} }

      context "and CORS headers have NOT been configured" do
        before do
          allow(app).to receive(:call)

          call
        end

        it "delegates to the app" do
          expect(app).to have_received(:call).with(env)
        end
      end

      context "and CORS headers have been configured" do
        let(:headers) { {"Access-Control-Allow-Origin" => "*"} }

        before do
          Liberty::CORS.config { |config| config.headers = headers }
        end

        it "returns a CORS response" do
          expect(call).to contain_exactly(200, a_hash_including(headers), [])
        end
      end
    end
  end
end
