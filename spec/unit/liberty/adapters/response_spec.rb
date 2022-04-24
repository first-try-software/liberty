# frozen_string_literal: true

RSpec.describe Liberty::Adapters::Response do
  describe "#to_rack_response" do
    subject(:to_rack_response) { described_class.new(endpoint).to_rack_response }

    let(:endpoint) { Class.new(Liberty::Endpoint).new }

    context "when endpoint returns a status" do
      let(:status) { 418 }

      before { allow(endpoint).to receive(:status).and_return(status) }

      it "returns the provided status" do
        expect(to_rack_response).to match_array([status, anything, anything])
      end
    end

    context "when the endpoint does NOT return headers" do
      context "and the content type is JSON" do
        before { allow(endpoint).to receive(:json).and_return({}) }

        it "adds an application/json content type to headers" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Type" => "application/json"),
            anything
          ])
        end
      end

      context "and the content type is HTML" do
        before { allow(endpoint).to receive(:html).and_return("<html></html>") }

        it "adds an text/html content type to headers" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Type" => "text/html"),
            anything
          ])
        end
      end

      context "and the content type is TEXT" do
        before { allow(endpoint).to receive(:text).and_return("UN TEXTO") }

        it "adds an text/plain content type to headers" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Type" => "text/plain"),
            anything
          ])
        end
      end

      context "and the content type is NOT specified" do
        before { allow(endpoint).to receive(:body).and_return("0x0123") }

        it "does not add a content type header" do
          expect(to_rack_response).to match_array([
            anything,
            hash_excluding({"Content-Type" => anything}),
            anything
          ])
        end
      end
    end

    context "when the endpoint returns headers" do
      context "and the headers are custom headers" do
        let(:headers) { {"X-Test-Header" => "Look Ma! I did a header!"} }

        before { allow(endpoint).to receive(:headers).and_return(headers) }

        it "returns the provided headers" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including(headers),
            anything
          ])
        end
      end

      context "and the headers do NOT include content type" do
        let(:headers) { {} }

        before do
          allow(endpoint).to receive(:headers).and_return(headers)
          allow(endpoint).to receive(:text).and_return("")
        end

        it "adds a content type header" do
          expect(to_rack_response).to match_array([
            anything,
            a_kind_of(Hash).and(have_key("Content-Type")),
            anything
          ])
        end
      end

      context "and the headers include content type" do
        let(:headers) { {"Content-Type" => "image/png"} }

        before do
          allow(endpoint).to receive(:headers).and_return(headers)
          allow(endpoint).to receive(:text).and_return("")
        end

        it "honors the user-provided content type" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Type" => "image/png"),
            anything
          ])
        end
      end

      context "and the headers do NOT include content length" do
        let(:headers) { {} }

        before do
          allow(endpoint).to receive(:headers).and_return(headers)
          allow(endpoint).to receive(:text).and_return("Freedøm!")
        end

        it "adds a content length header" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Length" => "9"),
            anything
          ])
        end
      end

      context "and the headers include content length" do
        let(:headers) { {"Content-Length" => "42"} }

        before do
          allow(endpoint).to receive(:headers).and_return(headers)
          allow(endpoint).to receive(:text).and_return("")
        end

        it "honors the user-provided content length" do
          expect(to_rack_response).to match_array([
            anything,
            a_hash_including("Content-Length" => "42"),
            anything
          ])
        end
      end
    end

    context "when there is NOT content" do
      before { allow(endpoint).to receive(:body).and_return("") }

      it "contains an empty string in the body" do
        expect(to_rack_response).to match_array([
          anything,
          anything,
          [""]
        ])
      end
    end

    context "when there is content" do
      context "and the content only includes JSON" do
        context "and the JSON contains a valid JSON string" do
          let(:json) { {key: "value"}.to_json }

          before { allow(endpoint).to receive(:json).and_return(json) }

          it "returns the valid JSON string" do
            expect(to_rack_response).to match_array([
              anything,
              anything,
              [json]
            ])
          end
        end

        context "and the JSON is NOT a valid JSON string" do
          let(:json) { {key: "value"} }

          before { allow(endpoint).to receive(:json).and_return(json) }

          it "returns a valid JSON string" do
            expect(to_rack_response).to match_array([
              anything,
              anything,
              [json.to_json]
            ])
          end
        end
      end

      context "and the content only includes HTML" do
        let(:html) { "<html></html>" }

        before { allow(endpoint).to receive(:html).and_return(html) }

        it "returns the HTML" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [html]
          ])
        end
      end

      context "and the content only includes text" do
        let(:text) { "text" }

        before { allow(endpoint).to receive(:text).and_return(text) }

        it "returns the text" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [text]
          ])
        end
      end

      context "and the content only includes a body" do
        let(:body) { "body" }

        before { allow(endpoint).to receive(:body).and_return(body) }

        it "returns the content" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [body]
          ])
        end
      end

      context "and the content includes JSON and HTML" do
        let(:json) { {key: "value"}.to_json }
        let(:html) { "<html></html>" }

        before do
          allow(endpoint).to receive(:json).and_return(json)
          allow(endpoint).to receive(:html).and_return(html)
        end

        it "returns the JSON" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [json]
          ])
        end
      end

      context "and the content includes HTML and text" do
        let(:html) { "<html></html>" }
        let(:text) { "text" }

        before do
          allow(endpoint).to receive(:html).and_return(html)
          allow(endpoint).to receive(:text).and_return(text)
        end

        it "returns the HTML" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [html]
          ])
        end
      end

      context "and the content includes text and body" do
        let(:text) { "text" }
        let(:body) { "body" }

        before do
          allow(endpoint).to receive(:text).and_return(text)
          allow(endpoint).to receive(:body).and_return(body)
        end

        it "returns the text" do
          expect(to_rack_response).to match_array([
            anything,
            anything,
            [text]
          ])
        end
      end
    end
  end
end
