class Object
  def bencode
    raise Bencode::Error.new("can't bencode #{self.class.to_s}")
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
    "d#{map{|k, v|[k.bencode, v.bencode]}.flatten.join}e"
  end
end

class Bencode
  def self.encode(object)
    object.bencode
  end

  class Error < Exception; end

  class ScanningString < String
    TOKENS = {?d => 1, ?l => 2, ?i => 3, ?: => 4, ?e => 5}
    STATES = {
      #     0  1  2  3  4  5
      0 => [4, 1, 2, 3, 4,-1], # parse started
      1 => [], # dictionary started
      2 => [], # list started
      3 => [6,-1,-1,-1,-1, 0], # integer started
      4 => [4,-1,-1,-1, 0,-1], # string length started
      6 => [6,-1,-1,-1,-1, 0], # integer body
    }

    def initialize(s)
      @pos = -1
      super(s)
    end

    def scan
      @pos += 1
      current = 0
      buffer = ''
      while @pos < size
        ch = self[@pos]
        token = ch.chr =~ /\d/ ? 0 : TOKENS[ch]
        state = STATES[current][token]
        case state
        when -1 # got syntax error
          return nil
        when 0 # started or continuing parse
          case current
          when 3 # empty integer
            return 0
          when 6 # integer
            return buffer.to_i
          when 4 # string
            len = buffer.to_i
            str = String.new(self[@pos + 1..@pos + len])
            @pos += len
            return str
          end
        when 1 # got dictionary
          dict = Hash.new
          while obj = scan
            dict[obj] = scan
          end
          return dict
        when 2 # got list
          list = Array.new
          while obj = scan
            list << obj
          end
          return list
        end
        if state != current
          buffer = ch.chr
        else
          buffer += ch.chr
        end
        current = state
        @pos += 1
      end
    end
  end

  def self.decode(s)
    ScanningString.new(s).scan
  end
end
