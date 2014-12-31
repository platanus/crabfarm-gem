require 'spec_helper'

describe Crabfarm::BaseParser do

  let(:env) { Surimi.build_fake_env }
  let(:bucket) { Object.new }

  let(:parser_class_a) { Class.new(Crabfarm::BaseParser) }
  let(:parser_class_b) { Class.new(Crabfarm::BaseParser) { browser_dsl :surimi_2 } }

  let(:parser_a) { parser_class_a.new env, bucket, { arg: 'imateapot' } }
  let(:parser_b) { parser_class_b.new env, bucket, { } }

  describe "browser" do
    it 'should be fed with driver bucket on initialization' do
      expect(parser_a.browser.bucket).to eq(bucket)
    end

    it 'should provide the dsl specified in configuration if no dsl is specified in parser' do
      expect(parser_a.browser.class).to be(Surimi::DslAdapter)
    end

    it 'should provide the dsl specified in parser' do
      expect(parser_b.browser.class).to be(Surimi::DslAdapter2)
    end
  end

  describe "params" do
    it 'should provide a access to external parameters' do
      expect(parser_a.params[:arg]).to eq('imateapot')
    end
  end
end
