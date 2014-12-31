require 'active_support'

module Crabfarm

  class Loader

    attr_reader :module

    def initialize(_base_path, _module=Object)
      @path = _base_path
      @module = _module
      @config = nil
      @source_loaded = false
    end

    def load(_overrides=nil)
      load_config _overrides
      load_source
    end

    def load_config(_overrides=nil)
      raise ConfigurationError.new 'Source already loaded, call unload_source first' if @source_loaded
      raise ConfigurationError.new 'Crabfile not found' unless File.exists? crafile_path

      @config = read_crabfile crafile_path
      @config.set _overrides unless _overrides.nil?
    end

    def load_source
      raise ConfigurationError.new 'Crabfile must be loaded first' if @config.nil?
      raise ConfigurationError.new 'Source already loaded, call reload_source instead' if @source_loaded

      require_from_path source_path
      @source_loaded = true
    end

    def unload_source
      # TODO: unload every class in a list
      @source_loaded = false
    end

    def reload_source
      unload_source if @source_loaded
      load_source
    end

    def is_loaded?
      @source_loaded
    end

    def load_context(_overrides={})
      raise ConfigurationError.new 'Must load source first' unless @source_loaded
      Context.new ModuleHelper.new @module, @config
    end

  private

    def crafile_path
      File.join @path, 'Crabfile'
    end

    def source_path
      File.join @path, 'app'
    end

    def read_crabfile(_path)
      config = Configuration.new
      config.instance_eval File.read crafile_path
      return config
    end

    def require_from_path(_src_path)
      @module.module_eval do
        # TODO: put every loaded class in a list, store last update or hash so next time is required
        # it can be reloaded automatically.

        pending = Dir.glob(File.join(_src_path, '**/*')).select { |f| f.end_with? '.rb' }.map { |f| f[0...-3] }

        while pending.size > 0
          new_pending = []
          pending.each do |file|
            begin
              require file
            rescue NameError => e
              new_pending << file
            end
          end

          require new_pending.first if new_pending.size == pending.size
          pending = new_pending
        end
      end
    end

  end

end
