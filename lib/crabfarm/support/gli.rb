module Crabfarm
  module Support
    module GLI
      def self.generate_options(_cmd)
        Configuration::OPTIONS.each do |opt|
          if opt.type != :mixed
            _cmd.desc opt.text
            _cmd.flag "cf-#{opt.name}"
          end
        end
      end

      def self.parse_options(_options)
        config_overrides = {}
        Configuration::OPTIONS.each do |opt|
          value = _options["cf-#{opt.name}"]
          next if value.nil?

          value = if opt.type.is_a? Array
            opt.type.find { |t| t.to_s == value }
          elsif opt.type == :integer then value.to_i
          elsif opt.type == :float then value.to_f
          elsif opt.type == :boolean then [true, false].find { |t| t.to_s == value }
          elsif opt.type == :string then value
          else nil end
          next if value.nil?

          config_overrides[opt.name] = value
        end
        config_overrides
      end
    end
  end
end