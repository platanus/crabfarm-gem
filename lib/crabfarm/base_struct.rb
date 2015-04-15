require "crabfarm/assertion/fields"

module Crabfarm
  class BaseStruct
    include Assertion::Fields

    def initialize(_values={})
      reset_fields
      _values.each { |k,v| send("#{k}=", v) }
    end

    def as_json(_options=nil)
      field_hash
    end

  end
end
