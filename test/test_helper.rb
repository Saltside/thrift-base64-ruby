require 'bundler/setup'

root = File.expand_path '../..', __FILE__

$LOAD_PATH << "#{root}/vendor/gen-rb"

require 'thrift-base64'

Thrift.type_checking = true

require 'json'

require 'test_types'
require 'minitest/autorun'
