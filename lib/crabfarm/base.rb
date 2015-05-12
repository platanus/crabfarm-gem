module Crabfarm
  module Base

    def debugger
      binding.pry if Crabfarm.debug?
    end

  end
end
