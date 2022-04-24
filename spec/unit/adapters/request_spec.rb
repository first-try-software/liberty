RSpec.describe Liberty::Adapters::Request do
  subject(:request) { described_class.new(env) }

  let(:env) { nil }

  describe '#headers' do
    subject(:headers) { request.headers }

    context 'when the env is nil' do
      let(:env) { nil }

      it 'returns an empty hash' do
        expect(headers).to eq({})
      end
    end

    context 'when the env is NOT nil' do
      let(:env) { {} }
      let(:rack_request) { instance_double(Rack::Request, accept_media_types: accept_media_types) }
      let(:accept_media_types) { [json_mime_type, html_mime_type] }
      let(:json_mime_type) { 'application/json' }
      let(:html_mime_type) { 'text/html' }

      before do
        allow(Rack::Request).to receive(:new).and_return(rack_request)
      end

      it 'delegates to Rack::Request to get the accept_media_types header' do
        headers

        expect(Rack::Request).to have_received(:new).with(env)
      end

      it 'includes the accept_media_types header' do
        expect(headers).to include(accept_media_types: accept_media_types)
      end

      it 'includes the preferred media type header' do
        expect(headers).to include(preferred_media_type: json_mime_type)
      end
    end
  end

  describe '#params' do
    subject(:params) { request.params }

    context 'when the env is nil' do
      let(:env) { nil }

      it 'returns an empty hash' do
        expect(params).to eq({})
      end
    end

    context 'when the env is NOT nil' do
      let(:env) { { 'router.params' => url_params } }
      let(:rack_request) { instance_double(Rack::Request, body: request_body, media_type: media_type, params: form_params) }
      let(:request_body) { instance_double('request_body', read: body_params.to_json, rewind: true) }
      let(:media_type) { 'application/json' }
      let(:form_params) { { 'form_param' => 'form_value' } }
      let(:body_params) { { 'body_param' => 'body_value' } }
      let(:url_params) { { url_param: 'url_value' } }

      before do
        allow(Rack::Request).to receive(:new).and_return(rack_request)
      end

      it 'delegates to Rack::Request to get form params' do
        params

        expect(Rack::Request).to have_received(:new).with(env)
      end

      it 'parses params out of the env form data' do
        expect(params).to include(form_param: 'form_value')
      end

      it 'parses params out of the env body' do
        expect(params).to include(body_param: 'body_value')
      end

      it 'parses params out of the env query string' do
        expect(params).to include(url_param: 'url_value')
      end
    end
  end
end
