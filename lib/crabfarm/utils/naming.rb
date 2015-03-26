module Crabfarm
  module Utils
    module Naming

      def self.is_constant_name?(_name)
        /^([A-Z][A-Za-z0-9]*)(\:\:[A-Z][A-Za-z0-9]*)*$/ === _name
      end

      def self.route_from_constant(_class_name)
        _class_name.split('::').map(&:underscore)
      end

      def self.decode_crabfarm_uri(_uri)
        _uri.to_s.split('/').map { |p| p.gsub(/[^A-Z0-9:]+/i, '_').camelize }.join('::')
      end

    end
  end
end
