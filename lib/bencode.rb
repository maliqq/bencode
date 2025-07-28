# frozen_string_literal: true

module Bencode
  class Error < StandardError; end

  class Scanner < String
    TOKENS = { 'd' => 1, 'l' => 2, 'i' => 3, ':' => 4, 'e' => 5 }.freeze
    STATES = {
      0 => [4, 1, 2, 3, 4, -1], # parse started
      1 => [],                  # dictionary started
      2 => [],                  # list started
      3 => [6, -1, -1, -1, -1, 0], # integer started
      4 => [4, -1, -1, -1, 0, -1], # string length started
      6 => [6, -1, -1, -1, -1, 0]  # integer body
    }.freeze

    def initialize(str)
      @pos = -1
      super(str)
    end

    def scan
      @pos += 1
      current = 0
      buffer = +''
      while @pos < size
        ch = self[@pos]
        token = ch =~ /\d/ ? 0 : TOKENS[ch]
        state = STATES[current][token]
        case state
        when -1
          return nil
        when 0
          case current
          when 3
            return 0
          when 6
            return buffer.to_i
          when 4
            len = buffer.to_i
            str = self[@pos + 1, len]
            @pos += len
            return str
          end
        when 1
          dict = {}
          while (obj = scan)
            dict[obj] = scan
          end
          return dict
        when 2
          list = []
          while (obj = scan)
            list << obj
          end
          return list
        end

        buffer = state != current ? ch : buffer + ch
        current = state
        @pos += 1
      end
    end
  end

  class << self
    def encode(object)
      object.bencode
    end

    def decode(str)
      Scanner.new(str).scan
    end
  end
end

class Object
  def bencode
    raise Bencode::Error, "can't bencode #{self.class}"
  end
end

class String
  def bencode
    "#{size}:#{self}"
  end
end

class Integer
  def bencode
    "i#{self}e"
  end
end

class Array
  def bencode
    "l#{map(&:bencode).join}e"
  end
end

class Symbol
  def bencode
    to_s.bencode
  end
end

class Hash
  def bencode
    "d#{map { |k, v| [k.bencode, v.bencode] }.flatten.join}e"
  end
end

