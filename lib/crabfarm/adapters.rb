require 'crabfarm/adapters/capybara_adapter'
require 'crabfarm/adapters/surfer_adapter'
require 'crabfarm/adapters/watir_adapter'

module Crabfarm
  module Adapters
    @@adapters = {}

    def self.register_dsl(_name, _adapter)
      @@adapters[_name.to_sym] = _adapter
    end

    def self.load_from_dsl_name _name
      raise ConfigurationError.new "Invalid dsl name #{_name}" unless @@adapters.has_key? _name.to_sym
      @@adapters[_name.to_sym]
    end

    # bundled adapters
    register_dsl :watir, WatirAdapter
    register_dsl :capybara, CapybaraAdapter
    register_dsl :surfer, SurferAdapter
  end
end
