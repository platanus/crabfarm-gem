module Crabfarm::Utils::Shell
  module Actionable

    class Action < Struct.new(:help, :callback); end

    def action(_description, _keys, &_callback)
      action = Action.new(_description, _callback)

      _keys = Array(_keys)
      _keys.each { |k| action_map[k] = action }
      nil
    end

    def handle_key(_key, _app)
      action = action_map[_key]
      return false if action.nil?
      action.callback.call(_key, _app)
      return true
    end

    def action_map
      @action_map ||= {}
    end

  end
end