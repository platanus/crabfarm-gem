module Crabfarm
  class TransitionService

    def self.apply_state(_context, _name, _params={})
      state_class = if _name.is_a? String or _name.is_a? Symbol
        load_by_name _name
      else _name end

      _context.prepare
      state = state_class.new _context, _params
      state.crawl
      state
    end

  private

    def self.load_by_name(_name)
      name = _name.to_s.gsub(/[^A-Z0-9:]+/i, '_').camelize
      name.constantize
    end

  end
end
