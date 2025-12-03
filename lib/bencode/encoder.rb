# frozen_string_literal: true

module Bencode
  class EncodeError < Error; end

  class Encoder
    def encode(object)
      case object
      when String
        encode_string(object)
      when Symbol
        encode_string(object.to_s)
      when Integer
        "i#{object}e"
      when Array
        "l#{object.map { |element| encode(element) }.join}e"
      when Hash
        encode_hash(object)
      else
        raise EncodeError, "Unsupported type for bencode: #{object.class}"
      end
    end

    private

    def encode_string(value)
      "#{value.bytesize}:#{value}"
    end

    def encode_hash(hash)
      entries = hash.keys.sort_by { |key| key_to_string(key) }.map do |key|
        encoded_key = encode_string(key_to_string(key))
        encoded_value = encode(hash.fetch(key))
        "#{encoded_key}#{encoded_value}"
      end

      "d#{entries.join}e"
    end

    def key_to_string(key)
      case key
      when String
        key
      when Symbol
        key.to_s
      else
        raise EncodeError, "Dictionary keys must be strings or symbols, got: #{key.class}"
      end
    end
  end
end
