require "crabfarm/assertion/parsers"
require "crabfarm/assertion/validations"

module Crabfarm
  module Assertion
    class Wrapper
      include Parsers
      include Validations

      def initialize(_value, _context=nil)
        @value = if _value.respond_to? :text
          _value.text
        else _value end

        @context = _context
      end

      def is_integer(_options={}, &_block)
        perform_assertion(_options) {
          @value = parse_integer @value, _options
          validate_number @value, _options
          validate_general @value, _options, &_block
        }
      end

      alias :is_i :is_integer

      def is_float(_options={}, &_block)
        perform_assertion(_options) {
          @value = parse_float @value, _options
          validate_number @value, _options
          validate_general @value, _options, &_block
        }
      end

      alias :is_f :is_float

      def is_word(_options={}, &_block)
        perform_assertion(_options) {
          @value = parse_phrase @value, _options
          validate_word @value, _options
          validate_general @value, _options, &_block
        }
      end

      alias :is_w :is_word

      def is_string(_options={}, &_block)
        perform_assertion(_options) {
          @value = parse_phrase @value, _options
          validate_string @value, _options
          validate_general @value, _options, &_block
        }
      end

      alias :is_s :is_string

      def is_boolean(_options={}, &_block)
        perform_assertion(_options) {
          @value = parse_boolean @value, _options, &_block
        }
      end

      alias :is_b :is_boolean

      def matches(_rgx, _options={})
        perform_assertion(_options) {
          match = _rgx.match @value
          fail_with "#{@value} does not match #{_rgx.to_s}" if match.nil?
          match
        }
      end

      def method_missing(_method, *_args)
        if @value.respond_to? :method
          @value = @value.send(*_args)
        else super end
      end

      def respond_to?(*args)
        @value.respond_to?(*args)
      end

    private

      def perform_assertion(_options)
        begin
          yield
          @value
        rescue AssertionError # => exc
          # for now just raise, in the future event could be hooked here...
          raise
        end
      end

      def fail_with(_message)
        raise AssertionError.new _message
      end

    end
  end
end
