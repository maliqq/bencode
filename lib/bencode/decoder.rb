# frozen_string_literal: true

module Bencode
  class DecodeError < Error; end

  class Decoder
    def initialize(payload)
      @payload = payload
      @index = 0
    end

    def decode
      result = read_value
      ensure_consumed!
      result
    end

    private

    attr_reader :payload

    def ensure_consumed!
      raise DecodeError, "Unexpected trailing data" if @index < payload.length
    end

    def read_value
      raise DecodeError, "Unexpected end of input" if @index >= payload.length

      case payload[@index]
      when 'i'
        read_integer
      when 'l'
        read_list
      when 'd'
        read_dictionary
      when /\d/
        read_string
      else
        raise DecodeError, "Unknown token: #{payload[@index].inspect}"
      end
    end

    def read_integer
      @index += 1
      terminator_index = payload.index('e', @index)
      raise DecodeError, "Unterminated integer" unless terminator_index

      number = payload[@index...terminator_index]
      raise DecodeError, "Invalid integer" unless number.match?(/^-?\d+$/)

      @index = terminator_index + 1
      number.to_i
    end

    def read_string
      length_end = payload.index(':', @index)
      raise DecodeError, "Invalid string length" unless length_end

      length = payload[@index...length_end].to_i
      raise DecodeError, "Negative string length" if length.negative?

      string_start = length_end + 1
      string_end = string_start + length
      raise DecodeError, "Unexpected end of string" if string_end > payload.length

      value = payload[string_start...string_end]
      @index = string_end
      value
    end

    def read_list
      @index += 1
      items = []
      until payload[@index] == 'e'
        raise DecodeError, "Unterminated list" if @index >= payload.length

        items << read_value
      end

      @index += 1
      items
    end

    def read_dictionary
      @index += 1
      dictionary = {}
      until payload[@index] == 'e'
        raise DecodeError, "Unterminated dictionary" if @index >= payload.length

        key = read_value
        unless key.is_a?(String)
          raise DecodeError, "Dictionary keys must be strings, got: #{key.class}"
        end

        dictionary[key] = read_value
      end

      @index += 1
      dictionary
    end
  end
end
