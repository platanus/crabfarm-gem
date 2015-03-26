module Crabfarm
  module GlobalState

    def inside_crawler_app?
      defined? CF_PATH
    end

    def app_path
      CF_PATH
    end

    def memento_path(_name)
      return nil if _name.nil?
      File.join(app_path, 'spec/mementos', _name + '.json.gz')
    end

    def snapshot_path(_file_name)
      return nil if _file_name.nil?
      File.join(app_path, 'spec/snapshots', _file_name)
    end

    extend self
  end
end