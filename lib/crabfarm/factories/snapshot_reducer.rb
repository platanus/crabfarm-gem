require 'crabfarm/factories/decorable'

module Crabfarm
  module Factories
    module SnapshotReducer
      include Decorable

      def self.default_build(_class, _path, _params)
        data = File.read _path
        Reducer.build(_class, data, _params)
      end
    end
  end
end