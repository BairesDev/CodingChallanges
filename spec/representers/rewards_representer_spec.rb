# frozen_string_literal: true

require 'representers/rewards_representer'

describe RewardsRepresenter do
  context 'when there are no json to represent' do
    it 'raise error' do
      expect {
        described_class.show('asdf')
      }.to raise_error RewardsRepresenter::InputError, 'Invalid input'
    end
  end

  context 'when input is valid' do
    let(:input) do
      {
        'Jessica'   => { points: 22, orders: 2 },
        'Will'      => { points: 3, orders: 2 },
        'Elizabeth' => { points: 0, orders: 0 }
      }
    end

    let(:response) { described_class.show(input) }

    it 'returns human readable messages' do
      expect(response).to eq([
        'Jessica: 22 with 11 points per order.',
        'Will: 3 with 1 points per order.',
        'Elizabeth: No orders.'
      ])
    end
  end
end
