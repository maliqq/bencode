# Bencode

A modern, minimal Ruby implementation of the [bencode](https://en.wikipedia.org/wiki/Bencode) encoding format with a small command-line interface.

## Installation

```bash
gem build bencode.gemspec
# gem install ./bencode-0.1.0.gem
```

## Library usage

```ruby
require "bencode"

payload = Bencode.encode({ "hello" => [1, "world"] })
# => "d5:hellol1e5:worldee"

object = Bencode.decode(payload)
# => {"hello"=>[1, "world"]}
```

Encoding supports strings, symbols, integers, arrays, and hashes (with string or symbol keys). Dictionary keys are sorted to produce deterministic output. Decoding returns plain Ruby strings, integers, arrays, and hashes.

## Command line

The `bencode` executable can decode bencoded input to pretty-printed JSON or encode JSON into bencode. Input defaults to STDIN and output defaults to STDOUT.

```bash
# Decode a torrent file to JSON
bencode --decode --file ./example.torrent

# Encode JSON to bencode, writing the output to a file
cat payload.json | bencode --encode --output payload.bencode
```

Options:

- `-e`, `--encode` – encode JSON input into bencode
- `-d`, `--decode` – decode bencode input into JSON (default)
- `-f`, `--file FILE` – read input from a file instead of STDIN
- `-o`, `--output FILE` – write output to a file instead of STDOUT
- `-h`, `--help` – show usage information

## Development

Run the test suite with:

```bash
bundle install
bundle exec rspec
```

Or using the default rake task:

```bash
bundle exec rake
```
