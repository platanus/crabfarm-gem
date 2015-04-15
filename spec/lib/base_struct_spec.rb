require 'spec_helper'

describe Crabfarm::BaseStruct do

  let(:struct_class) {
    Class.new(Crabfarm::BaseStruct) do

      has_integer :a_number
      has_field :a_field

    end
  }

  describe "initialize" do

    it 'should allow setting fields at initialization' do
      struct = struct_class.new a_field: 'imateapot', a_number: '$ 110'
      expect(struct.a_field).to eq('imateapot')
      expect(struct.a_number).to be 110
    end

    it 'should fail if a passed value is invalid for the corresponding field' do
      expect { struct_class.new a_number: 'notanumber' }.to raise_error Crabfarm::AssertionError
    end
  end

  describe "to_json" do
    it 'should properly render the struct fields as json' do
      expect(struct_class.new(a_field: 'imateapot', a_number: '$ 110').to_json).to eq(
        '{"a_number":110,"a_field":"imateapot"}'
      )
    end
  end
end
