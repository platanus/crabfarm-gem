require 'crabfarm/utils/shell/container_frame'
require 'crabfarm/utils/shell/layout_engine'

module Crabfarm::Utils::Shell

  class LayoutFrame < ContainerFrame

    def vertical
      true
    end

    def required_lines(_lines, _columns)
      if vertical
        solver = solve_vertical_dims _lines, _columns
        solver.required_dims.inject &:+
      else
        solver = solve_horizontal_dims _lines, _columns
        solver.dims.each_with_index.map do |dim, i|
          children[i].required_lines(_lines, dim)
        end.max
      end
    end

    def required_columns(_lines, _columns)
      if vertical
        solver = solve_vertical_dims _lines, _columns
        solver.dims.each_with_index.map do |dim, i|
          children[i].required_columns(dim, _columns)
        end.max
      else
        solver = solve_horizontal_dims _lines, _columns
        solver.required_dims.inject &:+
      end
    end

    def min_lines(_lines)
      result = children_boundary(:min_lines, _lines)
      vertical ? result.inject(&:+) : result.max
    end

    def min_columns(_columns)
      result = children_boundary(:min_columns, _columns)
      vertical ? result.max : result.inject(&:+)
    end

    def max_lines(_lines)
      result = children_boundary(:max_lines, _lines)
      return nil if result.any? &:nil?
      vertical ? result.inject(&:+) : result.max
    end

    def max_columns(_columns)
      result = children_boundary(:max_columns, _columns)
      return nil if result.any? &:nil?
      vertical ? result.max : result.inject(&:+)
    end

    def render(_context)
      offset = 0
      if vertical
        solver = solve_line_dims _context.lines, _context.columns
        solver.dims.each_with_index do |dim, i|
          render_child _context, children[i], offset, 0, dim, _context.columns
          offset += dim
        end
      else
        solver = solve_column_dims _context.lines, _context.columns
        solver.dims.each_with_index do |dim, i|
          render_child _context, children[i], 0, offset, _context.lines, dim
          offset -= dim
        end
      end

      # render_spacer _context, offset if offset < _context.lines
    end

  private

    def children_boundary(_name, _reference)
      children.map do |child|
        # TODO: support percentual boundaries based on reference
        child.options.fetch _name, child.frame.send(_name, _reference)
      end
    end

    def children_weight
      childs.map { |c| c.options.fetch(:weight, 1.0) }
    end

    def solve_vertical_dims(_lines, _columns)
      children_min_lines = children_boundary(:min_lines, _lines)
      children_max_lines = children_boundary(:max_lines, _lines)

      engine = LayoutEngine.new _lines, children_min_lines, children_max_lines, children_weight
      engine.solve(1) do |dims|
        dims.each_with_index.map do |dim, i|
          children[i].required_lines(dim, _columns)
        end
      end
    end

    def solve_horizontal_dims(_lines, _columns)
      children_min_columns = children_boundary(:min_columns, _columns)
      children_max_columns = children_boundary(:max_columns, _columns)

      engine = LayoutEngine.new _columns, children_min_columns, children_max_columns, children_weight
      engine.solve(1) do |dims|
        dims.each_with_index.map do |dim, i|
          children[i].required_columns(_lines, dim)
        end
      end
    end

    def render_child(_context, _child, _line, _column, _height, _width)
      child.render _context.child_context(_line, _column, _height, _width)
    end

    def render_spacer(_context, _offset)
      spacer_sz = _context.lines - _offset
      _context.goto_line _offset
      _context.write_line '-'*_context.columns
      (spacer_sz-1).times { _context.write_line '#'*_context.columns }
    end
  end
end