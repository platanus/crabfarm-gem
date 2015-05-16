require 'crabfarm/factories/decorable'

module Crabfarm
  module Factories
    module Navigator
      include Decorable

      def self.default_build(_class, _context, _params)
        _class.new _context, _params
      end

    end
  end
end