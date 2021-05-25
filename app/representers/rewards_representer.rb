# frozen_string_literal: true

class RewardsRepresenter
  class InputError < StandardError; end

  class << self
    def show(input)
      new(input).parse
    end
  end

  def initialize(input)
    raise InputError.new('Invalid input') unless input.is_a?(Hash)

    @input = input
  end

  def parse
    input.each_with_object([]) do |(key, value), response|
      response << Humanizer.new(key, value).to_s
    end
  end

  private

  attr_reader :input

  class Humanizer
    def initialize(customer, attrs)
      @customer = customer
      @attrs = attrs
    end

    def to_s
      return no_orders if orders.zero?

      "#{customer}: #{points} points with #{points_per_order} points per order."
    end

    private

    attr_reader :customer, :attrs

    def no_orders
      "#{customer}: No orders."
    end

    def points
      @points ||= attrs[:points]
    end

    def orders
      @orders ||= attrs[:orders] * 1.0
    end

    def points_per_order
      (points / orders).ceil
    end
  end
end
