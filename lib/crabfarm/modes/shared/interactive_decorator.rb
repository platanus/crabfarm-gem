require 'inquirer'
require 'crabfarm/modes/console'

module Crabfarm
  module Modes
    module Shared
      module InteractiveDecorator

        module Colors
          include Crabfarm::Modes::Console::Colors
        end

        class InteractiveHash < Hash

          def self.parse_input(_val)
            case _val
            when 'true' then true
            when 'false' then false
            when 'nil' then nil
            when /^\d+$/ then _val.to_i
            when /^\d*\.\d+$/ then _val.to_f
            when /^:[^\s]+$/ then _val.to_sym
            when /^\'.*?\'$/ then _val[1...-1]
            when /^\".*?\"$/ then _val[1...-1]
            else _val end
          end

          ['[]', :fetch, :has_key?, :key?, :include?].each do |method|
            define_method method do |*args|
              cache_value args[0]
              super(*args)
            end
          end

          def merge(*args)
            InteractiveHash.new.merge! super
          end

        private

          def cache
            @cache ||= self.to_h
          end

          def cache_value(_key)
            unless cache.key? _key
              value = cache[_key] = Ask.input("Value for '#{_key}'? (blank to skip)".color Colors::QUESTION).strip
              self[_key] = parse_input value unless value.empty?
            end
          end

          def parse_input(*_args)
            self.class.parse_input(*_args)
          end

        end

        def self.decorate(_navigator)

          def _navigator.params
            @i_params ||= InteractiveHash.new.merge! @params
          end

          _navigator
        end

      end

    end
  end
end