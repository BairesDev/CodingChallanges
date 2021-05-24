# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

%w[. app].each do |dir|
  $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
end

require 'dotenv/load'

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require_relative 'support/simple_cov'

require 'rack/test'
require 'rspec'

APPLICATION_PATH = File.expand_path("#{File.dirname(__FILE__)}/../")

require_relative 'support'

SPEC_PATH = __dir__
