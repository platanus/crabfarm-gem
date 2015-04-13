module Crabfarm
  module Dsl
    module Surfer
      class SurfContext < SearchContext

        attr_reader :driver

        def_delegators 'driver.navigate', :back, :forward, :refresh

        def initialize(_driver)
          super nil, self
          @driver = _driver
        end

        def root
          self
        end

        def elements
          [driver]
        end

        def to_html
          driver.page_source
        end

        def current_uri
          URI.parse driver.current_url
        end

        def cookies
          driver.manage.all_cookies
        end

        def goto(_url, _params=nil)
          _url += "?#{_params.to_query}" if _params
          driver.get(_url)
        end
      end
    end
  end
end
