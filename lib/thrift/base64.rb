require 'thrift/base64/version'
require 'thrift'
require 'base64'

module Thrift
  class Base64Serializer < Serializer
    def serialize(base)
      ::Base64.encode64 super
    end
  end

  class Base64Deserializer < Deserializer
    def deserialize(object, blob)
      super object, ::Base64.decode64(blob)
    end
  end

  # NOTE: this module is a little workaround in off the chance
  # another library has redefined Struct.included. So instead
  # we prepend a module which then extends the original including
  # class with the module containing from_base64.
  module Base64Extension
    module FromBase64
      def from_base64(blob, protocol = BinaryProtocolFactory.new)
        Base64Deserializer.new(protocol).deserialize(new, blob)
      end

      def from_compact_base64(blob)
        from_base64 blob, CompactProtocolFactory.new
      end
    end

    def included(base)
      base.extend FromBase64
      super
    end
  end

  module Struct
    class << self
      prepend Base64Extension
    end

    def to_base64(protocol = BinaryProtocolFactory.new)
      Base64Serializer.new(protocol).serialize self
    end

    def to_compact_base64
      to_base64 CompactProtocolFactory.new
    end
  end

  class Union
    extend Base64Extension::FromBase64

    def to_base64(protocol = BinaryProtocolFactory.new)
      Base64Serializer.new(protocol).serialize self
    end

    def to_compact_base64
      to_base64 CompactProtocolFactory.new
    end
  end
end
