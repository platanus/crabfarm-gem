module Crabfarm
  module Assertion
    module Validations

      def validate_number _value, _options={}
        fail_with "#{_value} out of range" if _options.key? :greater_than and _value <= _options[:greater_than]
        fail_with "#{_value} out of range" if _options.key? :greater_or_equal_to and _value < _options[:greater_or_equal_to]
        fail_with "#{_value} out of range" if _options.key? :less_than and _value >= _options[:less_than]
        fail_with "#{_value} out of range" if _options.key? :less_or_equal_to and _value > _options[:less_or_equal_to]
        fail_with "#{_value} out of range" if _options.key? :between and not _options[:between].include? _value
      end

      def validate_word _value, _options={}
        fail_with "'#{_value}' is not a single word" if /\s/ === _value
        validate_string _value, _options
      end

      def validate_string _value, _options={}
        fail_with "#{_value} does not match expression" if _options.key? :matches and not _options[:matches] === _value
        fail_with "#{_value} does not contain substring" if _options.key? :contains and !_value.include? _options[:contains]
      end

      def validate_general _value, _options={}, &_block
        fail_with "#{_value} is not recognized" if _options.key? :in and not _options[:in].include? _value
        fail_with "#{_value} is not valid" if _block and !_block.call(_value)
      end

    end
  end
end