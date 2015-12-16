require 'crabfarm/utils/shell/container_frame'
require 'crabfarm/utils/shell/layout_solver'

module Crabfarm::Utils::Shell

  class LinearLayoutFrame < ContainerFrame

    attr_reader :fluid

    def initialize(_options={})
      super()
      @fluid = _options.fetch :fluid, true
    end

  private

    def children_boundary(_name, _reference)
      children.map do |child|
        # TODO: support percentual boundaries based on reference
        child.options.fetch _name, child.frame.send(_name, _reference)
      end
    end

    def children_weight
      children.map { |c| c.options.fetch(:weight, 1.0) }
    end

    def solve_vertical_dims(_lines, _columns)
      children_min_lines = children_boundary(:min_lines, _lines)
      children_max_lines = children_boundary(:max_lines, _lines)

      engine = LayoutSolver.new _lines, children_min_lines, children_max_lines, children_weight
      engine.solve(fluid ? 2 : 1) do |dims|
        dims.each_with_index.map do |dim, i|
          children[i].frame.required_lines(dim, _columns)
        end
      end
    end

    def solve_horizontal_dims(_lines, _columns)
      children_min_columns = children_boundary(:min_columns, _columns)
      children_max_columns = children_boundary(:max_columns, _columns)

      engine = LayoutSolver.new _columns, children_min_columns, children_max_columns, children_weight
      engine.solve(fluid ? 2 : 1) do |dims|
        dims.each_with_index.map do |dim, i|
          children[i].frame.required_columns(_lines, dim)
        end
      end
    end

    def render_child(_context, _child, _line, _column, _height, _width)
      _child.frame.render _context.child_context(_line, _column, _height, _width)
    end
  end
end