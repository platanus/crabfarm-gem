require 'crabfarm/utils/shell/container_frame'

module Crabfarm::Utils::Shell

  class LayoutEngine

    attr_reader :dims

    def initialize(_available, _minimum, _maximum, _weight)
      @available = _available
      @minimum = _minimum
      @maximum = _maximum
      @weight = _weight
      @required = [0] ** @count
    end

    def required_dims
      @count.times.map do |i|
        next @minimum[i] if @required[i] < @minimum[i]
        next @maximum[i] if !@maximum[i].nil? and @required[i] > @maximum[i]
        @required[i]
      end
    end

    def solve(_iterations=1)
      # TODO: iterate until required sum converges?
      new_dims = @minimum.clone
      while _iterations > 0
        excess = @available - new_dims.inject(&:+)
        excess = distribute excess, new_dims, required_limits if excess > 0
        distribute excess, new_dims, maximum_limits if excess > 0
        @required = yield new_dims
        _iterations -= 1
      end
      @dims = new_dims
      self
    end

  private

    def distribute(_amount, _dims, _limits)
      # TODO: find a more efficient distribution algorithm!

      while _amount > 0
        selected = @count.times.inject(nil) do |r, i|
          next r if _dims[i] >= _limits[i]
          if r.nil? or (_dims[r] / @weight[r]) > (_dims[i] / @weight[i])
            i
          else
            r
          end
        end

        return _amount if selected.nil?
        _dims[selected] += 1
        _amount -= 1
      end

      return 0
    end

    def required_limits
      @count.times.map { |i| @required[i] < @maximum[i] ? @required[i] : @maximum[i] }
    end

    def maximum_limits
      @maximum
    end
  end
end