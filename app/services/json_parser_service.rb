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
  rescue TypeError
    raise_input_error
  end

  def call
    count_by_customer.sort_by { |_customer, attrs| -attrs[:points] }.to_h
  end

  private

  attr_reader :json

  def count_by_customer
    customers.each_with_object({}) do |customer, response|
      response[customer] = {
        points: points_by_customer(customer) || 0,
        orders: orders_by_customer(customer).count
      }
    end
  end

  def raise_input_error
    raise InputError, 'Invalid input'
  end

  def customers
    @customers ||= events.map { |i| i[:name] }.uniq.reject(&:nil?)
  end

  def events
    @events ||= json[:events]
  end

  def orders_by_customer(customer)
    events.select { |i| i[:customer] == customer && i[:action] == 'new_order' }
  end

  # Get all orders for informed customer
  # calculates the reward for each order
  # and sum all
  def points_by_customer(customer)
    orders_by_customer(customer)
      .map { |i| Reward.new(i).value }
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

    # Depending on the your, gives a factor to calculate the reward
    # 12pm - 1pm	1 point per $3 spent
    # 11am - 12pm and 1pm - 2pm	1 point per $2 spent
    # 10am - 11am and 2pm - 3pm	1 point per $1 spent
    # Any other time	0.25 points per $1
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
