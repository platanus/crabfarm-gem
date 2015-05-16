module Crabfarm
  module Utils
    module Resolve
      extend self

      def navigator_class(_name)
        if _name.is_a? String or _name.is_a? Symbol
          (Naming.decode_crabfarm_uri(_name.to_s)).constantize
        else _name end
      end

      def reducer_class(_name)
        if _name.is_a? String or _name.is_a? Symbol
          (Naming.decode_crabfarm_uri(_name.to_s) + 'Reducer').constantize
        else _name end
      end

      def memento_path(_name)
        File.join(mementos_path, _name.to_s + '.json.gz')
      end

      def snapshot_path(_name, _format)
        _name = self.to_s.underscore if _name.nil?
        File.join(snapshots_path, _name + '.' + parser.format)
      end

    private

      def mementos_path
        File.join(Crabfarm.app_path, 'spec/mementos')
      end

      def snapshots_path
        File.join(Crabfarm.app_path, 'spec/mementos')
      end

    end
  end
end
