require_relative 'test_helper'

class AcceptanceTest < MiniTest::Unit::TestCase
  attr_reader :struct

  def setup
    @struct = SimpleStruct.new message: utf8_string
    assert_utf8 struct.message
  end

  def test_round_trips_itself_with_proper_encodings
    base64 = Thrift::Base64Serializer.new.serialize(struct)

    deserialized = Thrift::Base64Deserializer.new.deserialize(SimpleStruct.new, base64)
    assert_equal struct.message, deserialized.message
    assert_utf8 deserialized.message
  end

  def test_generated_strings_can_be_used_in_encoding_aware_code
    base64 = Thrift::Base64Serializer.new.serialize(struct)
    roundtripped = JSON.load(JSON.dump(blob: base64)).fetch('blob')

    assert_equal base64, roundtripped

    deserialized = Thrift::Base64Deserializer.new.deserialize(SimpleStruct.new, roundtripped)
    assert_equal struct.message, deserialized.message
    assert_utf8 deserialized.message
  end

  def test_roundtrips_via_to_from_base64
    roundtripped = SimpleStruct.from_base64(struct.to_base64)
    assert_equal struct.message, roundtripped.message
  end

  def test_to_from_methods_take_protocol_argument
    compact_base64 = struct.to_base64 Thrift::CompactProtocolFactory.new
    expected = Base64.encode64(Thrift::Serializer.new(Thrift::CompactProtocolFactory.new).serialize(struct))

    assert expected == compact_base64, 'Protocol incorrect'

    deserialized = SimpleStruct.from_base64(compact_base64, Thrift::CompactProtocolFactory.new)
    assert_equal struct.message, deserialized.message
  end

  def test_to_from_compact_binary_with_base64_encoding
    compact_base64 = struct.to_compact_base64
    expected = Base64.encode64(Thrift::Serializer.new(Thrift::CompactProtocolFactory.new).serialize(struct))

    assert expected == compact_base64, 'Protocol incorrect'

    deserialized = SimpleStruct.from_compact_base64(compact_base64)
    assert_equal struct.message, deserialized.message
  end

  def test_works_with_unions
    union = SimpleUnion.new foo: 'set'

    roundtripped = SimpleUnion.from_base64(union.to_base64)
    assert_equal union.foo, roundtripped.foo

    roundtripped = SimpleUnion.from_compact_base64(union.to_compact_base64)
    assert_equal union.foo, roundtripped.foo
  end

  private

  def assert_utf8(string)
    assert_equal Encoding::UTF_8, string.encoding, 'Non UTF-8 string'
  end

  def utf8_string
    "Hi, I'am a ☃ !!"
  end
end
