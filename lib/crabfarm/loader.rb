require 'active_support'

module Crabfarm

  class Loader

    attr_reader :module

    def initialize(_base_path, _module_name=nil, &_config_block)
      @path = _base_path
      @name = _module_name
      @config_block = _config_block
      @module = if is_wrapped? then
        "::#{@name}".constantize rescue nil
      else nil end
    end

    def is_wrapped?
      @name.present?
    end

    def is_loaded?
      not @module.nil?
    end

    def load
      crabfile = load_crabfile(@path)
      @module = load_module(@name, File.join(@path, 'app'))
      @module.send(:remove_const, :CF_CONFIG) rescue nil
      @module.const_set :CF_CONFIG, crabfile
    end

    def load_context
      load unless is_loaded?
      Context.new @module
    end

    def unload
      Object.send(:remove_const, @name) if is_wrapped?
      @module = nil
    end

  private

    def load_crabfile(_path)
      crabfile = File.read(File.join(_path, 'Crabfile'))
      config = Configuration.new
      config.instance_eval crabfile
      @config_block.call(config) unless @config_block.nil?
      return config
    end

    def load_module(_name, _path)
      require_all_as(_name, _path)
      if is_wrapped? then "::#{_name}".constantize else Object end
    end

    def require_all_as(_name, _src_path)
      loader_code = "
        pending = Dir.glob('#{File.join(_src_path, '**/*')}').select { |f| f.end_with? '.rb' }.map { |f| f[0...-3] }

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
      "

      loader_code = "module ::#{_name}; #{loader_code}; end" if _name.present?
      Object.instance_eval loader_code
    end

  end

end
