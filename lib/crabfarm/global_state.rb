module Crabfarm
  module GlobalState

    def inside_crawler_app?
      defined? CF_PATH
    end

    def app_path
      CF_PATH
    end

    def memento_path(_name)
      File.join(app_path, 'spec/mementos', _name + '.json.gz')
    end

    def snapshot_path(_file)
      File.join(app_path, 'spec/snapshots', _file)
    end

    extend self
  end
end