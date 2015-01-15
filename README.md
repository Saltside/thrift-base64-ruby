# thrift-base64

This gem contains helper classes for working with Base64 encoded
Thrift objects. Eventually code will need to persist a serialized
Thrift object. The binary protocols are the fastest ones.
Unfortunately binary doesn't work well with plaintext protocols.
Base64 solves this problem. It's also much faster than working with
the provided `Thrift::JSON` protocol for interlop with plaintext
protocols. Just check out the benchmarks below.

## Benchmarks

	ruby benchmark/serialization.rb
	Calculating -------------------------------------
					JSON   739.000  i/100ms
				  Binary     4.532k i/100ms
				 Compact     7.174k i/100ms
		   Binary Base64     3.951k i/100ms
		  Compact Base64     6.660k i/100ms
	-------------------------------------------------
					JSON      7.369k (±16.3%) i/s -    106.416k
				  Binary     50.965k (± 9.8%) i/s -    756.844k
				 Compact     87.953k (± 8.5%) i/s -      1.313M
		   Binary Base64     43.881k (±10.2%) i/s -    651.915k
		  Compact Base64     87.340k (± 9.3%) i/s -      1.299M

	Comparison:
				 Compact:    87953.3 i/s
		  Compact Base64:    87340.1 i/s - 1.01x slower
				  Binary:    50964.6 i/s - 1.73x slower
		   Binary Base64:    43880.7 i/s - 2.00x slower
					JSON:     7369.0 i/s - 11.94x slower

	ruby benchmark/plaintext.rb
	Calculating -------------------------------------
		JSON/JSON String   690.000  i/100ms
		JSON/JSON Object   651.000  i/100ms
			 JSON/Binary     2.554k i/100ms
			JSON/Compact     3.329k i/100ms
		YAML/YAML String   355.000  i/100ms
			 YAML/Binary   575.000  i/100ms
			YAML/Compact   607.000  i/100ms
	-------------------------------------------------
		JSON/JSON String      7.093k (± 8.6%) i/s -    105.570k
		JSON/JSON Object      6.834k (±10.0%) i/s -    101.556k
			 JSON/Binary     28.120k (± 8.4%) i/s -    418.856k
			JSON/Compact     36.468k (± 8.3%) i/s -    542.627k
		YAML/YAML String      3.636k (±13.8%) i/s -     52.895k
			 YAML/Binary      6.118k (± 9.5%) i/s -     90.850k
			YAML/Compact      6.541k (±10.3%) i/s -     97.120k

	Comparison:
			JSON/Compact:    36468.5 i/s
			 JSON/Binary:    28120.3 i/s - 1.30x slower
		JSON/JSON String:     7093.4 i/s - 5.14x slower
		JSON/JSON Object:     6834.5 i/s - 5.34x slower
			YAML/Compact:     6540.9 i/s - 5.58x slower
			 YAML/Binary:     6118.3 i/s - 5.96x slower
		YAML/YAML String:     3636.5 i/s - 10.03x slower

These benchmarks are included in [benchmark/][benchmark/].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thrift-base64'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install thrift-base64

## Usage

`thrift-base64` adds two classes to the `Thrift` module:
`Thrift::Base64Derserializer` & `Thrift::Base64Serializer`. They mimic the
interface of `Thirft::Deserializer` & `Thrift::Serializer`.

```ruby
require 'thrift-base64'

struct = SomeThriftStruct.new

json = Thrift::Base64Serializer.new.serialize(struct)
deserialized = Thrift::Base64Deserializer.new.deserialize(SomeThriftStruct.new, json)
```

Here's another example if you don't like the verbosity. Defaults to
using `Thrift::BinaryProtocol`.

```ruby
require 'thrift-base64'

struct = SomeThriftStruct.new
SomeThriftStruct.from_base64(struct.to_base64)
```

Compact methods are available as well. They use
`Thrift::CompactProtocol`.

```
require 'thrift-base64'

struct = SomeThriftStruct.new
SomeThriftStruct.from_compact_base64(struct.to_compact_base64)
```

## Testing

	$ make test
	$ make benchmark

## Contributing

1. Fork it ( https://github.com/saltside/thrift-base64-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[thrift]: https://thrift.apache.org
