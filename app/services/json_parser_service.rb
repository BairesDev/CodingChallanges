# frozen_string_literal: true

require 'json'

class JsonParserService
  class InputError < StandardError; end

  class << self
    def call(...)
      new(...).call
    end
  end

  def initialize(json)
    @json = JSON.parse(json).deep_symbolize_keys

    raise_input_error if @json.empty?
  rescue TypeError => e
    raise_input_error
  end

  def call
    customers.each_with_object({}) do |customer, response|
      response[customer] = { points: points_by_customer(customer) }
    end
  end

  private

  attr_reader :json

  def raise_input_error
    raise InputError, 'Invalid input'
  end

  def customers
    @customers ||= events.map { |i| i[:name] }.uniq.reject(&:nil?)
  end

  def events
    @events ||= json[:events]
  end

  # Get all orders for informed customer
  # calculates the reward for each order
  # and sum all
  def points_by_customer(customer)
    events.select { |i| i[:name] == customer && i[:action] == 'new_order' }
          .map    { |i| Reward.new(i).value }
          .inject(:+)
  end

  class Reward
    def initialize(order)
      @order = order
    end

    def value
      reward < 3 || reward > 20 ? 0 : reward
    end

    private

    attr_reader :order

    def amount
      @amount ||= order[:amount] * 1.0
    end

    def hour
      @hour ||= Time.parse(order[:timestamp]).hour
    end

    def reward
      @reward ||= (amount / factor).ceil
    end

    def factor
      {
        12 => 3,
        11 => 2,
        13 => 2,
        10 => 1,
        14 => 1
      }[hour] || 0.25
    end
  end
end
