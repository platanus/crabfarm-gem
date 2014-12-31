# Collection of fake structures
module Surimi

  class Driver
  end

  class DriverFactory
    def self.build_driver(_session_id)
      Driver.new
    end
  end

  class DslAdapter < Struct.new(:bucket)
    def self.wrap(_bucket)
      DslAdapter.new _bucket
    end
  end

  class DslAdapter2 < Struct.new(:bucket)
    def self.wrap(_bucket)
      DslAdapter2.new _bucket
    end
  end

  def self.build_fake_env(_module=nil, _config={})
    config = Crabfarm::Configuration.new
    config.set_default_dsl :surimi
    config.set_driver_factory DriverFactory

    return Crabfarm::ModuleHelper.new _module, config
  end

end

Crabfarm::Adapters.register_dsl :surimi, Surimi::DslAdapter
Crabfarm::Adapters.register_dsl :surimi_2, Surimi::DslAdapter2
