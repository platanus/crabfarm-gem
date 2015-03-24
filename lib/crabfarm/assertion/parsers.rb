module Crabfarm
  module Assertion
    module Parsers

      def parse_integer _value, _options={}
        parse_number :to_i, _value, _options
      end

      def parse_float _value, _options={}
        parse_number :to_f, _value, _options
      end

      def parse_phrase _value, _options={}
        fail_with_nil if _value.nil?

        if _value.is_a? String
          clean_string _value, _options
        else
          if _value.respond_to? :to_s
            clean_string _value.to_s, _options
          else
            fail_with "Value cannot be transformed to string"
          end
        end
      end

      def parse_boolean _value, _options={}
        truthy = Array(_options.fetch(:truthy, ['true']))
        falsy = Array(_options.fetch(:falsy, ['false']))

        mapping = { :empty => false, true => true, false => false }
        truthy.each { |k| mapping[k] = true }
        falsy.each { |k| mapping[k] = false }

        parse_by_map _value, mapping
      end

      def parse_by_map _value, _map={}
        fail_with_nil if _value.nil?

        case _value
        when String, Symbol
          _value = _value.strip if _value.is_a? String
          return parse_by_map :empty, _map if _value.empty?
          fail_with "'#{_value.to_s}' is and invalid keyword" unless _map.key? _value
          _map[_value]
        else
          fail_with "'#{_value}' cannot be mapped"
        end
      end

      def parse_number _to_fun, _value, _options={}
        fail_with_nil if _value.nil?

        if _value.is_a? String
          _value.strip!
          if _value.empty?
            return_default _options
          else
            extract_number_from_string(_value, _options).send _to_fun
          end
        elsif _value.respond_to? _to_fun
          _value.send _to_fun
        else
          fail_with "'#{_value}' cannot be transformed to number"
        end
      end

      def clean_string _string, _options
        normalized = _string.strip.gsub(/\s+/, ' ')
        if normalized.empty?
          return_default _options
        else normalized end
      end

      def fail_with_nil
        fail_with "'nil' cant be parsed"
      end

      def return_default _options
        fail_with "Value is an empty" unless _options.key? :default
        _options[:default]
      end

      def extract_number_from_string _value, _options
        decimal_mark = _options.fetch(:decimal_mark, '.') # TODO: make default decimal mark configurable
        thousand_mark = _options.fetch(:thousand_mark, infer_thousand_separator(decimal_mark))
        num_rgx = Regexp.new "-?(?:\\#{decimal_mark}\\d+|\\d{1,3}(?:\\#{thousand_mark}\\d{3})+(?:\\#{decimal_mark}\\d+)?|\\d+(?:\\#{decimal_mark}\\d+)?)"
        matches = _value.scan num_rgx
        fail_with "'#{_value}' has an ambiguous numeric format" if matches.count > 1
        fail_with "'#{_value}' does not contain any number" if matches.count < 1
        matches.first.gsub(thousand_mark,'').gsub(decimal_mark, '.')
      end

      def infer_thousand_separator _decimal_mark
        case _decimal_mark
        when '.' then ','
        when ',' then '.'
        else '' end
      end

    end
  end
end