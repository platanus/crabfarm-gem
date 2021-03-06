# Mock structures using for tests

class FakeBrowserDsl1 < Struct.new(:bucket)
  def self.wrap(_bucket)
    FakeBrowserDsl1.new _bucket
  end
end

class FakeBrowserDsl2 < Struct.new(:bucket)
  def self.wrap(_bucket)
    FakeBrowserDsl2.new _bucket
  end
end

class FakeParserEngine1 < Struct.new(:html)
  def self.format
    'html'
  end

  def self.parse(_html)
    FakeParserEngine1.new _html
  end

  def self.preprocess_parsing_target(_target)
    _target
  end
end

class FakeParserEngine2 < FakeParserEngine1
  def self.parse(_html)
    FakeParserEngine2.new _html
  end
end


Crabfarm::Strategies.register :webdriver_dsl, :fake_dsl_1, FakeBrowserDsl1
Crabfarm::Strategies.register :webdriver_dsl, :fake_dsl_2, FakeBrowserDsl2

Crabfarm::Strategies.register :parser, :fake_engine_1, FakeParserEngine1
Crabfarm::Strategies.register :parser, :fake_engine_2, FakeParserEngine2


class MockNavigatorA < Crabfarm::BaseNavigator

  def run
  end

end

class MockNavigatorB < Crabfarm::BaseNavigator

  def run
  end

end

class MockNavigatorAReducer < Crabfarm::BaseReducer

  def run
  end

end

class FakeReducer

  attr_accessor :target, :params

  def initialize(_target, _params)
    @target = _target
    @params = _params
  end

  def run
  end

end