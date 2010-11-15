require 'spec_helper'
require 'bencode'

describe Bencode do
  it "should encode string" do
    Bencode.encode("hello").should == '5:hello'
    Bencode.encode("world").should == '5:world'
    Bencode.encode("Hello,World!").should == '12:Hello,World!'
    Bencode.encode(:symbol).should == '6:symbol'
  end

  it "should encode integer" do
    Bencode.encode(111).should == 'i111e'
    Bencode.encode(2222).should == 'i2222e'
  end

  it "should encode list" do
    Bencode.encode([1,2,3]).should == "li1ei2ei3ee"
    Bencode.encode([1,'2','3']).should == "li1e1:21:3e"
  end

  it "should encode dictionary" do
    Bencode.encode({'hello' => 'world'}).should == 'd5:hello5:worlde'
  end
end

describe Bencode do
  it "should decode string" do
    Bencode.decode("5:hello").should == 'hello'
    Bencode.decode("0:").should == ''
  end

  it "should decode integer" do
    Bencode.decode('i111111e').should == 111111
    Bencode.decode('i2222e').should == 2222
    Bencode.decode('ie').should == 0
  end

  it "should decode list" do
    Bencode.decode('li33ei66ei99ee').should == [33, 66, 99]
  end

  it "should decode hash" do
    Bencode.decode('di35e8:testtest').should == {35 => 'testtest'}
  end

  it "should decode complex structures" do
    obj = {35 => [1,2], '3' => 4, '555' => [66, '7777'], 8 => {9 => 10}}
    Bencode.decode(obj.bencode).should == obj
  end
end

describe Bencode do
  it "should parse torrent files" do
    Dir["#{Rails.root}/spec/fixtures/*.torrent"].each do |f|
      lambda {
        torrent_data = Bencode.decode(File.open(f).read)
        File.open(f.gsub('.torrent', '.yaml'), 'w') {|ff|
          ff << torrent_data.to_yaml
        }
      }.should_not raise_exception(Exception)
    end
  end
end

describe Bencode do
  it "should raise error" do
    lambda {
      (0.22).bencode
    }.should raise_exception(Bencode::Error)
  end
end
