require 'bundler/setup'
require 'thrift-base64'

root = File.expand_path '../..', __FILE__

$LOAD_PATH << "#{root}/vendor/gen-rb"

Thrift.type_checking = true

require 'test_types'
require 'benchmark/ips'

require 'json'
require 'yaml'

struct = SimpleStruct.new message: 'Benchmarking!!'

json_serializer = Thrift::Serializer.new Thrift::JsonProtocolFactory.new
json_deserializer = Thrift::Deserializer.new Thrift::JsonProtocolFactory.new

binary_base64_serializer = Thrift::Base64Serializer.new Thrift::BinaryProtocolFactory.new
binary_base64_deserializer = Thrift::Base64Deserializer.new Thrift::BinaryProtocolFactory.new

compact_base64_serializer = Thrift::Base64Serializer.new Thrift::CompactProtocolFactory.new
compact_base64_deserializer = Thrift::Base64Deserializer.new Thrift::CompactProtocolFactory.new

# Cover the various blobs when used inside other plaintext protocols
Benchmark.ips do |x|
  x.warmup = 5
  x.time = 15

  x.report "JSON/JSON String" do
    json_deserializer.deserialize(SimpleStruct.new, JSON.load(JSON.dump([ json_serializer.serialize(struct) ])).first)
  end

  x.report "JSON/JSON Object" do
    json_deserializer.deserialize(SimpleStruct.new, JSON.load(JSON.dump({ blob: json_serializer.serialize(struct) })).fetch('blob'))
  end

  x.report "JSON/Binary" do
    binary_base64_deserializer.deserialize(SimpleStruct.new, JSON.load(JSON.dump([ binary_base64_serializer.serialize(struct) ])).first)
  end

  x.report "JSON/Compact" do
    compact_base64_deserializer.deserialize(SimpleStruct.new, JSON.load(JSON.dump([ compact_base64_serializer.serialize(struct) ])).first)
  end

  x.report "YAML/YAML String" do
    json_deserializer.deserialize(SimpleStruct.new, YAML.load(YAML.dump([ json_serializer.serialize(struct) ])).first)
  end

  x.report "YAML/Binary" do
    binary_base64_deserializer.deserialize(SimpleStruct.new, YAML.load(YAML.dump([ binary_base64_serializer.serialize(struct) ])).first)
  end

  x.report "YAML/Compact" do
    compact_base64_deserializer.deserialize(SimpleStruct.new, YAML.load(YAML.dump([ compact_base64_serializer.serialize(struct) ])).first)
  end

  x.compare!
end
