require 'bundler/setup'
require 'thrift-base64'

root = File.expand_path '../..', __FILE__

$LOAD_PATH << "#{root}/vendor/gen-rb"

Thrift.type_checking = true

require 'test_types'
require 'benchmark/ips'

struct = SimpleStruct.new message: 'Benchmarking!!'

json_serializer = Thrift::Serializer.new Thrift::JsonProtocolFactory.new
json_deserializer = Thrift::Deserializer.new Thrift::JsonProtocolFactory.new

binary_serializer = Thrift::Serializer.new Thrift::BinaryProtocolFactory.new
binary_deserializer = Thrift::Deserializer.new Thrift::BinaryProtocolFactory.new

compact_serializer = Thrift::Serializer.new Thrift::CompactProtocolFactory.new
compact_deserializer = Thrift::Deserializer.new Thrift::CompactProtocolFactory.new

binary_base64_serializer = Thrift::Base64Serializer.new Thrift::BinaryProtocolFactory.new
binary_base64_deserializer = Thrift::Base64Deserializer.new Thrift::BinaryProtocolFactory.new

compact_base64_serializer = Thrift::Base64Serializer.new Thrift::CompactProtocolFactory.new
compact_base64_deserializer = Thrift::Base64Deserializer.new Thrift::CompactProtocolFactory.new

Benchmark.ips do |x|
  x.warmup = 5
  x.time = 15

  x.report "JSON" do
    json_deserializer.deserialize(SimpleStruct.new, json_serializer.serialize(struct))
  end

  x.report "Binary" do
    binary_deserializer.deserialize(SimpleStruct.new, binary_serializer.serialize(struct))
  end

  x.report "Compact" do
    compact_deserializer.deserialize(SimpleStruct.new, compact_serializer.serialize(struct))
  end

  x.report "Binary Base64" do
    binary_base64_deserializer.deserialize(SimpleStruct.new, binary_base64_serializer.serialize(struct))
  end

  x.report "Compact Base64" do
    compact_deserializer.deserialize(SimpleStruct.new, compact_serializer.serialize(struct))
  end

  x.compare!
end
