require 'spec_helper'
require 'crabfarm/assertion/fields'

describe Crabfarm::Assertion::Fields do

  let(:instance) {
    Class.new do
      include Crabfarm::Assertion::Fields

      string :a_string
      word :a_word
      integer :an_integer
      float :a_float
      array :an_array

      def initialize
        reset_fields
      end

    end.new
  }

  describe "self.asserted_field" do
    it { expect { instance.a_string = 'valid string' }.not_to raise_error }
    it { expect { instance.a_string = '  ' }.to raise_error Crabfarm::AssertionError }
    it { expect { instance.an_integer = ' 111  ' }.not_to raise_error }
    it { expect { instance.an_integer = ' 11 11 ' }.to raise_error Crabfarm::AssertionError }
  end

  describe "field_hash" do

    before {
      instance.a_string = ' im a teapot'
      instance.a_float = '22.220'
    }

    it "should contain setted values and defaults" do
      expect(instance.field_hash).to eq({
        a_string: 'im a teapot',
        a_word: nil,
        an_integer: nil,
        a_float: 22.22,
        an_array: []
      })
    end

  end


end