THRIFT:=vendor/gen-rb/test_types.rb

$(THRIFT): test.thrift
	mkdir -p $(@D)
	thrift -o vendor --gen rb test.thrift

.PHONY: test
test: $(THRIFT)
	bundle exec rake test

.PHONY:
release:
	bundle exec rake release

.PHONY: benchmark
benchmark: $(THRIFT)
	ruby benchmark/serialization.rb
	ruby benchmark/plaintext.rb
