require 'spec_helper'

describe Crabfarm::BaseParser do

  before {
    Crabfarm.config.set_parser_dsl :surimi
  }

  let(:parser_class_a) { Class.new(Crabfarm::BaseParser) }
  let(:parser_class_b) { Class.new(Crabfarm::BaseParser) { parser_dsl :surimi_2 } }

  let(:html_a) { '<div></div>' }
  let(:html_b) { '<span></span>' }

  let(:parser_a) { parser_class_a.new html_a, { arg: 'imateapot' } }
  let(:parser_b) { parser_class_b.new html_b, { } }

  describe "root" do
    it 'should be loaded with the html root node representation on initialization' do
      expect(parser_a.root.html).to eq(html_a)
    end

    it 'should provide the dsl specified in configuration if no dsl is specified in parser' do
      expect(parser_a.root.class).to be(Surimi::ParserDsl)
    end

    it 'should provide the dsl specified in parser' do
      expect(parser_b.root.class).to be(Surimi::ParserDsl2)
    end
  end

  describe "params" do
    it 'should provide a access to external parameters' do
      expect(parser_a.params[:arg]).to eq('imateapot')
    end
  end
end
