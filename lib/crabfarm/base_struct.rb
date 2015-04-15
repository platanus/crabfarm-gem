require "crabfarm/assertion/fields"

module Crabfarm
  class BaseStruct
    include Assertion::Fields

    def initialize(_values={})
      reset_fields
      _values.each { |k,v| send("#{k}=", v) }
    end

    def to_json(_options={})
      field_hash.to_json _options
    end

  end
end
