module Crabfarm
  class TransitionService

    def self.apply_state(_context, _name, _params={})
      state_class = if _name.is_a? String or _name.is_a? Symbol
        load_class_from_uri _name
      else _name end

      _context.prepare
      state = state_class.new _context, _params
      state.crawl
      state
    end

  private

    def self.load_class_from_uri(_uri)
      class_name = Utils::Naming.decode_crabfarm_uri _uri
      class_name.constantize
    end

  end
end
