# frozen_string_literal: true

require_relative "lib/bencode/version"

Gem::Specification.new do |spec|
  spec.name          = "bencode"
  spec.version       = Bencode::VERSION
  spec.authors       = ["Example Maintainer"]
  spec.email         = ["maintainer@example.com"]

  spec.summary       = "A small bencode encoder/decoder"
  spec.description   = "Modern Ruby library and CLI for encoding and decoding bencoded data."
  spec.homepage      = "https://example.com/bencode"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md", "LICENSE"]
  spec.bindir        = "bin"
  spec.executables   = ["bencode"]
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com/bencode"
  spec.metadata["changelog_uri"] = "https://example.com/bencode/changelog"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
