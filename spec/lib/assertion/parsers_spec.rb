require 'spec_helper'
require 'crabfarm/assertion/parsers'

describe Crabfarm::Assertion::Parsers do

  let(:srv) {
    Class.new do
      extend Crabfarm::Assertion::Parsers

      def self.fail_with(_message)
        raise Crabfarm::AssertionError.new _message
      end
    end
  }

  describe "parse_number" do

    context "wnen parsing nil or empty" do
      it { expect(srv.parse_number(nil, ' ', default: 10)).to eq(10) }
      it { expect { srv.parse_number(nil, nil, default: 10) }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_number(nil, ' ') }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_number(nil, nil) }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_number(nil, '1.0.0.1', default: 10) }.to raise_error Crabfarm::AssertionError }
    end

    context "when looking for integers" do
      it { expect(srv.parse_integer('10.10')).to eq(10) }
      it { expect(srv.parse_integer('-10.10')).to eq(-10) }
      it { expect(srv.parse_integer('.10')).to eq(0) }
      it { expect(srv.parse_integer('10,100')).to eq(10100) }
      it { expect(srv.parse_integer('10,100.10')).to eq(10100) }
      it { expect(srv.parse_integer('10.100,10', decimal_mark: ',')).to eq(10100) }
      it { expect(srv.parse_integer('10 100 100', thousand_mark: ' ')).to eq(10100100) }
      it { expect(srv.parse_integer('10 US')).to eq(10) }
      it { expect(srv.parse_integer('only 10 items')).to eq(10) }

      it { expect(srv.parse_integer(10)).to eq(10) }
      it { expect(srv.parse_integer(10.9)).to eq(10) }
    end

    context "when looking for floats" do
      it { expect(srv.parse_float('10 US')).to eq(10.0) }
      it { expect(srv.parse_float('only 10.2 items')).to eq(10.2) }
      it { expect(srv.parse_float('10.10')).to eq(10.1) }
      it { expect(srv.parse_float('-10.10')).to eq(-10.1) }
      it { expect(srv.parse_float('.10')).to eq(0.1) }
      it { expect(srv.parse_float('10,100')).to eq(10100.0) }
      it { expect(srv.parse_float('10,100.10')).to eq(10100.1) }

      it { expect(srv.parse_float(10.9)).to eq(10.9) }
      it { expect(srv.parse_float(10)).to be_a Float }
    end

    context "when parsing invalid numbers" do
      it { expect { srv.parse_integer('10 10') }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_integer('10.100.10') }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_integer('hello') }.to raise_error Crabfarm::AssertionError }
    end
  end

  describe "parse_phrase" do

    context "wnen parsing nil or empty" do
      it { expect(srv.parse_phrase('    ', default: 'phrase')).to eq('phrase') }
      it { expect { srv.parse_phrase(nil, default: 'phrase') }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_phrase('   ') }.to raise_error Crabfarm::AssertionError }
      it { expect { srv.parse_phrase(nil) }.to raise_error Crabfarm::AssertionError }
    end

    it { expect(srv.parse_phrase(' hello   world   ')).to eq('hello world') }
    it { expect(srv.parse_phrase(10)).to eq('10') }

  end

  describe "parse_boolean" do

    context "wnen parsing nil or empty" do
      it { expect(srv.parse_boolean('  ')).to eq(false) }
      it { expect { srv.parse_boolean(nil) }.to raise_error Crabfarm::AssertionError }
    end

    it { expect(srv.parse_boolean('true')).to be(true) }
    it { expect(srv.parse_boolean('false')).to be(false) }
    it { expect(srv.parse_boolean('yes', truthy: 'yes')).to be(true) }
    it { expect(srv.parse_boolean('yes', truthy: ['yes','ok'])).to be(true) }
    it { expect(srv.parse_boolean('niet', falsy: ['niet'])).to be(false) }
    it { expect { srv.parse_boolean('niet', falsy: ['no']) }.to raise_error Crabfarm::AssertionError }
  end

  describe "parse_date" do
    skip "parsing dates is a pending feature"
  end

end