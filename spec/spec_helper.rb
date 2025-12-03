# frozen_string_literal: true

require "bundler/setup"
require "bencode"
require "json"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end
