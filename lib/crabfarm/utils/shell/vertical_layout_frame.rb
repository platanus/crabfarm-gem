require 'crabfarm/utils/shell/linear_layout_frame'
require 'crabfarm/utils/shell/vertical_separator'

module Crabfarm::Utils::Shell

  class VerticalLayoutFrame < LinearLayoutFrame

    def add_separator
      add_frame VerticalSeparator.new
    end

    def required_lines(_lines, _columns)
      solver = solve_vertical_dims _lines, _columns
      solver.required_dims.inject &:+
    end

    def required_columns(_lines, _columns)
      solver = solve_vertical_dims _lines, _columns
      solver.dims.each_with_index.map do |dim, i|
        children[i].required_columns(dim, _columns)
      end.max
    end

    def min_lines(_lines)
      children_boundary(:min_lines, _lines).inject(&:+)
    end

    def min_columns(_columns)
      children_boundary(:min_columns, _columns).max
    end

    def max_lines(_lines)
      result = children_boundary(:max_lines, _lines)
      return nil if result.any? &:nil?
      result.inject(&:+)
    end

    def max_columns(_columns)
      result = children_boundary(:max_columns, _columns)
      return nil if result.any? &:nil?
      result.max
    end

    def render(_context)
      offset = 0
      solver = solve_vertical_dims _context.lines, _context.columns
      solver.dims.each_with_index do |dim, i|
        render_child _context, children[i], offset, 0, dim, _context.columns
        offset += dim
      end
    end
  end
end