# frozen_string_literal: true

require 'services/json_parser_service'

describe JsonParserService do
  context 'when input is invalid' do
    it 'raise error' do
      expect {
        described_class.call({ foo: :bar })
      }.to raise_error JsonParserService::InputError, 'Invalid input'
    end
  end

  context 'when input is empty' do
    it 'raise error' do
      expect {
        described_class.call({}.to_json)
      }.to raise_error JsonParserService::InputError, 'Invalid input'
    end
  end

  context 'when a customer has no orders' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $3 expend' do
      expect(response['Jessica']).to eq(points: 0, orders: 0)
    end
  end

  context 'when reward points is < 3' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 3.5, timestamp: '2020-07-01T12:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives no reward' do
      expect(response['Jessica']).to eq(points: 0, orders: 1)
    end
  end

  context 'when reward points is > 20' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 10, timestamp: '2020-07-01T09:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives no reward' do
      expect(response['Jessica']).to eq(points: 0, orders: 1)
    end
  end

  context 'when a customer has an order between 12pm - 1pm' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 16.5, timestamp: '2020-07-01T12:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $3 expend' do
      expect(response['Jessica']).to eq(points: 6, orders: 1)
    end
  end

  context 'when a customer has an order between 11am - 12pm' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 16.5, timestamp: '2020-07-01T11:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $2 expend' do
      expect(response['Jessica']).to eq(points: 9, orders: 1)
    end
  end

  context 'when a customer has an order between 10am - 11am' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 16.5, timestamp: '2020-07-01T10:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $1 expend' do
      expect(response['Jessica']).to eq(points: 17, orders: 1)
    end
  end

  context 'when a customer has an order between 2pm - 2pm' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 16.5, timestamp: '2020-07-01T14:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $1 expend' do
      expect(response['Jessica']).to eq(points: 17, orders: 1)
    end
  end

  context 'when a customer has an order between 2pm - 2pm' do
    let(:json) do
      {
        events: [
          { action: 'new_customer', name: 'Jessica', timestamp: '2020-07-01T00:00:00-05:00' },
          { action: 'new_order', customer: 'Jessica', amount: 3, timestamp: '2020-07-01T09:01:00-05:00' }
        ]
      }
    end

    let(:response) { described_class.call(json.to_json) }

    it 'gives 1 point for $0.25 expend' do
      expect(response['Jessica']).to eq(points: 12, orders: 1)
    end
  end

  context 'when it runs over the whole provided json' do
    let(:json) { JSON.parse(File.read(File.join(SPEC_PATH, 'fixtures', 'sample_input.json'))).deep_symbolize_keys }

    let(:response) { described_class.call(json.to_json) }

    it 'creates a key on hash with the customer' do
      expect(response.keys).to eq(%w[Jessica Will Elizabeth])
    end

    it 'gives the right amount for each customer' do
      expect(response).to eq(
        'Jessica' => { points: 22, orders: 2 },
        'Will' => { points: 3, orders: 2 },
        'Elizabeth' => { points: 0, orders: 0 }
      )
    end
  end
end
