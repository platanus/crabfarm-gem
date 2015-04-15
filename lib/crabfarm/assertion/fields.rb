require "active_support/core_ext/object/duplicable"
require 'crabfarm/assertion/context'

module Crabfarm
  module Assertion
    module Fields
      include Context

      module ClassMethods

        def has_field(_name, _options={})
          name = _name.to_sym

          fields << name
          field_defaults[name] = _options.delete :field_default

          assertion = _options.delete :field_assertion
          if assertion
            define_method("#{name}=") { |v| field_hash[name] = assert(v).send(assertion, _options) }
          elsif not _options[:field_readonly]
            define_method("#{name}=") { |v| field_hash[name] = v }
          end

          define_method(name) { field_hash[name] }
        end

        def has_asserted_field(_name, _assertion, _options={})
          has_field(_name, _options.merge(field_assertion: _assertion))
        end

        def has_array(_name)
          has_field(_name, field_default: [], field_readonly: true)
        end

        def has_integer(_name, _options={})
          has_asserted_field _name, :is_integer, _options
        end

        def has_float(_name, _options={})
          has_asserted_field _name, :is_float, _options
        end

        def has_string(_name, _options={})
          has_asserted_field _name, :is_string, _options
        end

        def has_word(_name, _options={})
          has_asserted_field _name, :is_word, _options
        end

        def has_boolean(_name, _options={})
          has_asserted_field _name, :is_boolean, _options
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