require 'crabfarm/utils/shell/container_frame'

module Crabfarm::Utils::Shell

  class LayoutFrame < ContainerFrame

    def req_lines
      @req_lines
    end

    def min_lines
      @min_lines
    end

    def prepare
      super # prepare childs first

      @req_dims = load_required_dims
      @req_lines = @req_dims.inject(0, &:+)
      @min_lines = load_required_dims.inject(0, &:+)
    end

    def render(_context)
      dims = @req_dims
      total_dims = @req_lines
      if total_dims > _context.lines
        dims = ensure_minimum _context.lines
        total_dims = dims.inject(&:+)
      end

      if _context.lines > total_dims
        distribute_excess(dims, _context.lines - total_dims)
      end

      offset = render_childs _context, dims
      render_spacer _context, offset if offset < _context.lines
    end

    def load_required_dims
      childs.map(&:req_lines)
    end

    def load_minimum_dims
      childs.map(&:min_lines)
    end

    def ensure_minimum(_space, _fixed=[])
      total_w = childs.reject { |c| _fixed.include? c }.map(&:weight).inject(0.0, &:+)
      real_space = (_space - _fixed.map(&:min_lines).inject(0, &:+)).to_f

      childs.map do |child|
        if _fixed.include? child
          child.min_lines
        else
          dim = (child.weight * real_space / total_w).round
          if dim < child.min_lines
            return load_weighted_dims(_space, _fixed << child)
          elsif dim > child.req_lines
            dim = child.req_lines
          end
          dim
        end
      end
    end

    def distribute_excess(_dims, _excess)
      remaining = distribute_excess_to_needed _dims, _excess
      remaining = distribute_excess_to_growable _dims, remaining if remaining > 0
      remaining
    end

    def distribute_excess_to_needed(_dims, _excess)
      need_excess = []
      total_w = 0.0

      _dims.each_with_index do |dim, i|
        if dim < childs[i].req_lines
          total_w += childs[i].weight
          need_excess << i
        end
      end

      return _excess if need_excess.length == 0

      need_excess.each do |i|
        assigned = (_excess.to_f * childs[i].weight / total_w).round
        assigned = childs[i].req_lines - _dims[i] if _dims[i] + assigned > childs[i].req_lines

        _excess -= assigned
        total_w -= childs[i].weight
        _dims[i] += assigned
      end

      return 0 if _excess == 0

      distribute_excess_to_needed _dims, _excess
    end

    def distribute_excess_to_growable(_dims, _excess)
      growable = []
      available = _excess
      total_w = 0.0

      _dims.each_with_index do |dim, i|
        if childs[i].grows?
          growable << i
          available += dim
          total_w += childs[i].weight
        end
      end

      growable.each do |i|
        new_dim = (available.to_f * childs[i].weight / total_w).round
        assigned = new_dim < _dims[i] ? 0 : (new_dim - _dims[i])
        assigned = new_dim - _dims[i]
        assigned = _excess if assigned > _excess

        total_w -= childs[i].weight
        _excess -= assigned
        _dims[i] += assigned
      end

      _excess
    end

    def render_childs(_context, _dims)
      offset = 0
      childs.each_with_index do |child, i|
        child.render _context.child_context(offset, 0, _dims[i], _context.columns)
        offset += _dims[i]
      end
      return offset
    end

    def render_spacer(_context, _offset)
      spacer_sz = _context.lines - _offset
      _context.goto_line _offset
      _context.write_line '-'*_context.columns
      (spacer_sz-1).times { _context.write_line '#'*_context.columns }
    end
  end
end