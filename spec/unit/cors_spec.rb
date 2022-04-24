RSpec.describe Liberty::CORS do
  describe '.headers=' do
    context 'when the incoming headers are NOT in a hash' do
      it 'raises an error' do
        expect { described_class.headers = 'Headers' }.to raise_error(ArgumentError)
      end
    end

    context 'when the incoming headers are in a hash' do
      it 'does not raise an error' do
        expect { described_class.headers = { key: 'value' } }.not_to raise_error
      end
    end
  end
end
