require 'rainbow'
require 'rainbow/ext/string'
require 'erb'
require 'ostruct'

module Crabfarm
  module Modes
    module Generator

      def generate_app(_target, _name, _default_remote=nil)
        with_base_path _target do
          binding = {
            name: _name,
            remote: _default_remote,
            version: Crabfarm::VERSION
          }

          path(_name).ensure
          path(_name, '.gitignore').render('dot_gitignore')
          path(_name, 'Gemfile').render('Gemfile', binding)
          path(_name, 'Crabfile').render('Crabfile', binding)
          path(_name, '.rspec').render('dot_rspec', binding)
          path(_name, '.crabfarm').render('dot_crabfarm', binding)
          path(_name, 'boot.rb').render('boot.rb', binding)
          path(_name, 'bin', 'crabfarm').render('crabfarm_bin', binding, 0755)
          path(_name, 'app', 'reducers', '.gitkeep').render('dot_gitkeep')
          path(_name, 'app', 'navigators', '.gitkeep').render('dot_gitkeep')
          path(_name, 'app', 'helpers', '.gitkeep').render('dot_gitkeep')
          path(_name, 'spec', 'spec_helper.rb').render('spec_helper.rb', binding)
          path(_name, 'spec', 'snapshots', '.gitkeep').render('dot_gitkeep')
          path(_name, 'spec', 'mementos', '.gitkeep').render('dot_gitkeep')
          path(_name, 'spec', 'integration', '.gitkeep').render('dot_gitkeep')
          path(_name, 'logs', '.gitkeep').render('dot_gitkeep')
        end
      end

      def generate_navigator(_target, _class_name)
        validate_class_name _class_name

        route = Utils::Naming.route_from_constant _class_name
        with_base_path _target do
          binding = { navigator_class: _class_name }
          path(*(['app', 'navigators'] + route[0...-1] + [route.last + '.rb'])).render('navigator.rb', binding)
          path(*(['spec', 'navigators'] + route[0...-1] + [route.last + '_spec.rb'])).render('navigator_spec.rb', binding)
        end
      end

      def generate_reducer(_target, _class_name)
        validate_class_name _class_name

        _class_name = _class_name + 'Reducer'
        route = Utils::Naming.route_from_constant _class_name
        with_base_path _target do
          binding = { reducer_class: _class_name }
          path(*(['app', 'reducers'] + route[0...-1] + [route.last + '.rb'])).render('reducer.rb', binding)
          path(*(['spec', 'reducers'] + route[0...-1] + [route.last + '_spec.rb'])).render('reducer_spec.rb', binding)
        end
      end

      def with_base_path(_target)
        @base_path = _target
        yield
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
          render_op "mkdir", path, :green
          dir.mkpath
        else
          render_op "skip", path, :yellow unless _silent
        end
      end

      def render_template(_template, _binding, _path, _mod)
        template = File.join(template_dir, _template) + '.erb'
        output = File.join(*_path)

        unless Pathname.new(output).exist?
          render_op "render", output, :green
          File.open(output, "w") do |f|
            f.write eval_template_with_hash(template, _binding)
            f.chmod(_mod) unless _mod.nil?
          end
        else
          render_op "skip", output, :yellow
        end
      end

      def eval_template_with_hash(_path, _hash)
        erb = ERB.new(File.read _path)
        erb.result(OpenStruct.new(_hash).instance_eval { binding })
      end

      def template_dir
        File.expand_path('../../templates', __FILE__)
      end

      def render_op(_op, _message, _color)
        puts _op.rjust(10).color(_color) + '  ' + _message
      end

      def validate_class_name(_name)
        raise Crabfarm::ArgumentError.new "Invalid class name '#{_name}'" unless Utils::Naming.is_constant_name? _name
      end

      extend self
    end
  end
end
