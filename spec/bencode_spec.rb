# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "json"

RSpec.describe Bencode do
  describe ".encode" do
    it "encodes strings and symbols" do
      expect(described_class.encode("hello")).to eq("5:hello")
      expect(described_class.encode(:symbol)).to eq("6:symbol")
    end

    it "encodes integers" do
      expect(described_class.encode(2222)).to eq("i2222e")
    end

    it "encodes lists" do
      expect(described_class.encode([1, "2", "3"])).to eq("li1e1:21:3e")
    end

    it "encodes dictionaries with sorted keys" do
      encoded = described_class.encode({ "b" => 1, "a" => 2 })
      expect(encoded).to eq("d1:ai2e1:bi1ee")
    end

    it "raises on unsupported types" do
      expect { described_class.encode(0.22) }.to raise_error(Bencode::EncodeError)
    end
  end

  describe ".decode" do
    it "decodes strings" do
      expect(described_class.decode("5:hello")).to eq("hello")
      expect(described_class.decode("0:")).to eq("")
    end

    it "decodes integers" do
      expect(described_class.decode("i111111e")).to eq(111_111)
      expect(described_class.decode("ie")).to eq(0)
    end

    it "decodes lists" do
      expect(described_class.decode("li33ei66ei99ee")).to eq([33, 66, 99])
    end

    it "decodes dictionaries" do
      expect(described_class.decode("di35e8:testtest")).to eq({ "35" => "testtest" })
    end

    it "decodes complex structures" do
      object = { "35" => [1, 2], "3" => 4, "555" => [66, "7777"], "8" => { "9" => 10 } }
      expect(described_class.decode(described_class.encode(object))).to eq(object)
    end

    it "raises on malformed payloads" do
      expect { described_class.decode("di35e") }.to raise_error(Bencode::DecodeError)
    end
  end

  describe "CLI" do
    let(:executable) { File.expand_path("../bin/bencode", __dir__) }

    it "decodes from a file" do
      Tempfile.create("input.bencode") do |file|
        file.write("5:hello")
        file.flush

        output = `#{executable} --decode --file #{file.path}`.strip
        expect(JSON.parse(output)).to eq("hello")
      end
    end

    it "encodes JSON from stdin" do
      json = { greeting: "hi" }.to_json
      output = IO.popen([executable, "--encode"], "r+") do |io|
        io.write(json)
        io.close_write
        io.read
      end

      expect(output).to eq("d8:greeting2:hie")
    end

    it "writes to an output file" do
      Tempfile.create("input.bencode") do |input|
        Tempfile.create("output.json") do |output|
          input.write("i42e")
          input.flush

          system(executable, "--decode", "--file", input.path, "--output", output.path)
          expect(JSON.parse(File.read(output.path))).to eq(42)
        end
      end
    end
  end
end
