require 'spec_helper'

describe Crabfarm::BaseReducer do

  before {
    Crabfarm.config.set_parser :fake_engine_1
  }

  let(:reducer_class_a) { Class.new(Crabfarm::BaseReducer) }
  let(:reducer_class_b) { Class.new(Crabfarm::BaseReducer) { use_parser :fake_engine_2 } }

  let(:html_a) { '<div></div>' }
  let(:html_b) { '<span></span>' }

  let(:reducer_a) { reducer_class_a.new html_a, { arg: 'imateapot' } }
  let(:reducer_b) { reducer_class_b.new html_b, { } }

  describe "document" do
    it 'should be loaded with the html root node representation on initialization' do
      expect(reducer_a.document.html).to eq(html_a)
    end

    it 'should provide the dsl specified in configuration if no dsl is specified in parser' do
      expect(reducer_a.document.class).to be(FakeParserEngine1)
    end

    it 'should provide the engine specified in use_parser' do
      expect(reducer_b.document.class).to be(FakeParserEngine2)
    end
  end

  describe "params" do
    it 'should provide a access to external parameters' do
      expect(reducer_a.params[:arg]).to eq('imateapot')
    end
  end
end
