require 'crabfarm/utils/shell/linear_layout_frame'
require 'crabfarm/utils/shell/horizontal_separator'

module Crabfarm::Utils::Shell

  class HorizontalLayoutFrame < LinearLayoutFrame

    def add_separator
      add_frame HorizontalSeparator.new
    end

    def required_lines(_lines, _columns)
      solver = solve_horizontal_dims _lines, _columns
      solver.dims.each_with_index.map do |dim, i|
        children[i].required_lines(_lines, dim)
      end.max
    end

    def required_columns(_lines, _columns)
      solver = solve_horizontal_dims _lines, _columns
      solver.required_dims.inject &:+
    end

    def min_lines(_lines)
      children_boundary(:min_lines, _lines).max
    end

    def min_columns(_columns)
      children_boundary(:min_columns, _columns).inject(&:+)
    end

    def max_lines(_lines)
      result = children_boundary(:max_lines, _lines)
      return nil if result.any? &:nil?
      result.max
    end

    def max_columns(_columns)
      result = children_boundary(:max_columns, _columns)
      return nil if result.any? &:nil?
      result.inject(&:+)
    end

    def render(_context)
      offset = 0
      solver = solve_horizontal_dims _context.lines, _context.columns
      solver.dims.each_with_index do |dim, i|
        render_child _context, children[i], 0, offset, _context.lines, dim
        offset += dim
      end
    end
  end
end