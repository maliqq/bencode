# frozen_string_literal: true

module Bencode
  class Error < StandardError; end
end

require_relative "bencode/version"
require_relative "bencode/encoder"
require_relative "bencode/decoder"

module Bencode
  module_function

  def encode(object)
    Encoder.new.encode(object)
  end

  def decode(payload)
    Decoder.new(payload).decode
  end
end
