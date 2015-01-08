require 'rainbow'
require 'rainbow/ext/string'
require 'active_support'
require 'erb'
require 'ostruct'

module Crabfarm
  module Modes
    class Generator

      def generate_app(_name, _target)
        with_external_path _target do
          binding = {
            name: _name,
            version: Crabfarm::VERSION
          }

          path(_name).ensure
          path(_name, '.gitignore').render('dot_gitignore')
          path(_name, 'Gemfile').render('Gemfile', binding)
          path(_name, 'Crabfile').render('Crabfile', binding)
          path(_name, '.rspec').render('dot_rspec', binding)
          path(_name, 'boot.rb').render('boot.rb', binding)
          path(_name, 'bin', 'crabfarm').render('crabfarm_bin', binding, 0755)
          path(_name, 'app', 'parsers', '.gitkeep').render('dot_gitkeep')
          path(_name, 'app', 'states', '.gitkeep').render('dot_gitkeep')
          path(_name, 'app', 'helpers', '.gitkeep').render('dot_gitkeep')
          path(_name, 'spec', 'spec_helper.rb').render('spec_helper.rb', binding)
          path(_name, 'spec', 'snapshots', '.gitkeep').render('dot_gitkeep')
        end
      end

      def generate_state(_name)
        with_crawler_path do
          binding = { state_class: _name.camelize }
          path('app', 'states', _name.underscore + '.rb').render('state.rb', binding)
          path('spec', 'states', _name.underscore + '_spec.rb').render('state_spec.rb', binding)
        end
      end

      def generate_parser(_name)
        with_crawler_path do
          binding = { parser_class: _name.camelize }
          path('app', 'parsers', _name.underscore + '.rb').render('parser.rb', binding)
          path('spec', 'parsers', _name.underscore + '_spec.rb').render('parser_spec.rb', binding)
        end
      end

      def with_external_path(_target)
        @base_path = _target
        yield
      end

      def with_crawler_path
        if defined? CF_PATH
          @base_path = CF_PATH
          yield
        else
          puts "This command can only be run inside a crabfarm application"
        end
      end

      def path(*_args)
        @path = _args
        self
      end

      def ensure
        generate_dir([@base_path] + @path, false)
        self
      end

      def render(_template, _binding={}, _mod=nil)
        path = [@base_path] + @path
        generate_dir(path[0..-2], true)
        render_template(_template, _binding, path, _mod)
        self
      end



  private

      def generate_dir(_path, _silent)
        path = File.join(*_path)
        dir = Pathname.new path
        unless dir.exist?
          puts "Generating #{path}".color(:green)
          dir.mkpath
        else
          puts "Skipping #{path}".color(:yellow) unless _silent
        end
      end

      def render_template(_template, _binding, _path, _mod)
        template = File.join(template_dir, _template) + '.erb'
        output = File.join(*_path)

        unless Pathname.new(output).exist?
          puts "Rendering #{output}".color(:green)
          File.open(output, "w") do |f|
            f.write eval_template_with_hash(template, _binding)
            f.chmod(_mod) unless _mod.nil?
          end
        else
          puts "Skipping #{output}, already exists".color(:yellow)
        end
      end

      def eval_template_with_hash(_path, _hash)
        erb = ERB.new(File.read _path)
        erb.result(OpenStruct.new(_hash).instance_eval { binding })
      end

      def template_dir
        File.expand_path('../../templates', __FILE__)
      end
    end
  end
end
