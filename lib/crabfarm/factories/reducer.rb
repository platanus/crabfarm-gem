require 'crabfarm/factories/decorable'

module Crabfarm
  module Factories
    module Reducer
      include Decorable

      def self.default_build(_class, _target, _params)
        _class.new _target, _params
      end

    end
  end
end