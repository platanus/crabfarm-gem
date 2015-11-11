require 'spec_helper'
require 'crabfarm/assertion/validations'

describe Crabfarm::Assertion::Validations do

  let(:srv) {
    Class.new do
      extend Crabfarm::Assertion::Validations

      def self.fail_with(_message)
        raise Crabfarm::AssertionError.new _message
      end
    end
  }

  describe "validate_number" do
    it { expect { srv.validate_number(8, greater_than: 10) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_number(10, greater_than: 10) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_number(15, greater_than: 10) }.not_to raise_error }

    it { expect { srv.validate_number(8, greater_or_equal_to: 10) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_number(10, greater_or_equal_to: 10) }.not_to raise_error }
    it { expect { srv.validate_number(15, greater_or_equal_to: 10) }.not_to raise_error }

    it { expect { srv.validate_number(8, less_than: 10) }.not_to raise_error }
    it { expect { srv.validate_number(10, less_than: 10) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_number(15, less_than: 10) }.to raise_error Crabfarm::AssertionError }

    it { expect { srv.validate_number(8, less_or_equal_to: 10) }.not_to raise_error }
    it { expect { srv.validate_number(10, less_or_equal_to: 10) }.not_to raise_error }
    it { expect { srv.validate_number(15, less_or_equal_to: 10) }.to raise_error Crabfarm::AssertionError }

    it { expect { srv.validate_number(8, between: 1..10) }.not_to raise_error }
    it { expect { srv.validate_number(10, between: 1..10) }.not_to raise_error }
    it { expect { srv.validate_number(15, between: 1...15) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_number(15, between: 1..15) }.not_to raise_error }
  end

  describe "validate_string" do
    it { expect { srv.validate_string('hello world', matches: /frog/) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_string('hello frog', matches: /frog/) }.not_to raise_error }
    it { expect { srv.validate_string('foo bar cow', contains: 'cat') }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_string('foo bar cow', contains: 'bar') }.not_to raise_error }
  end

  describe "validate_word" do
    it { expect { srv.validate_word('hello world') }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_word('hello') }.not_to raise_error }
  end

  describe "validate_general" do
    it { expect { srv.validate_general('foo', in: ['bar', 'pow']) }.to raise_error Crabfarm::AssertionError }
    it { expect { srv.validate_general('bar', in: ['foo', 'bar']) }.not_to raise_error }
    it { expect { srv.validate_general('bar') { |f| f == 'bar' }  }.not_to raise_error }
    it { expect { srv.validate_general('bar') { |f| f == 'foo' }  }.to raise_error Crabfarm::AssertionError }
  end

end