require 'crabfarm/assertion/context'

module Crabfarm
  module Assertion
    module Fields
      include Context

      module ClassMethods

        def field(_name)
          _name = _name.to_sym

          fields << _name

          define_method "#{_name}=" do |_value|
            field_hash[_name] = _value
          end

          define_method _name do
            field_hash[_name]
          end
        end

        def array(_name)
          _name = _name.to_sym

          fields << _name
          field_defaults[_name] = []

          define_method _name do |_value|
            field_hash[_name]
          end
        end

        def asserted_field(_name, _assertion, _options={})
          _name = _name.to_sym

          fields << _name

          define_method "#{_name}=" do |_value|
            field_hash[_name] = assert(_value).send(_assertion, _options)
          end

          define_method _name do
            field_hash[_name]
          end
        end

        def integer(_name, _options={})
          asserted_field _name, :is_integer, _options
        end

        def float(_name, _options={})
          asserted_field _name, :is_float, _options
        end

        def string(_name, _options={})
          asserted_field _name, :is_string, _options
        end

        def word(_name, _options={})
          asserted_field _name, :is_word, _options
        end

        def boolean(_name, _options={})
          asserted_field _name, :is_boolean, _options
        end

        def fields
          @fields ||= []
        end

        def field_defaults
          @field_defaults ||= {}
        end

      end

      def self.included(klass)
        klass.extend ClassMethods
      end

      def reset_fields
        klass = self.class

        @field_hash = {}
        klass.fields.each do |field|
          value = klass.field_defaults[field]
          @field_hash[field] = value.duplicable? ? value.clone : value
        end
      end

      def field_hash
        @field_hash
      end

      def to_json(_options={})
        field_hash.to_json(_options)
      end

    end
  end
end