require 'crabfarm/dsl/surfer/search_context'
require 'crabfarm/dsl/surfer/surf_context'

module Crabfarm
  module Dsl
    module Surfer

      class Error < StandardError
        attr_reader :source

        def initialize(_message, _ctx)
          super _message
          @ctx = _ctx
          @source = _ctx.root.page_source rescue nil # cache page source for future reference
        end
      end

      class EmptySetError < Error; end
      class WebdriverError < Error; end
    end
  end
end
