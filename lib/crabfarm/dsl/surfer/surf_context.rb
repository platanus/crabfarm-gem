module Crabfarm
  module Dsl
    module Surfer
      class SurfContext < SearchContext

        def_delegators :@bucket, :setup
        def_delegators 'driver.navigate', :back, :forward, :refresh

        def initialize(_bucket)
          super nil, self
          @bucket = _bucket
        end

        def root
          self
        end

        def elements
          [driver]
        end

        def source
          driver.page_source
        end

        def driver
          @bucket.original
        end

        def quit
          @bucket.reset
        end

        def current_uri
          URI.parse driver.current_url
        end

        def cookies
          driver.manage.all_cookies
        end

        def goto(_url, _params=nil)
          _url += "?#{_params.to_query}" if _params
          retries = 0

          loop do
            begin
              @bucket.reset if retries > 0
              driver.get(_url)
              break
            rescue Timeout::Error #, Selenium::WebDriver::Error::UnknownError
              # TODO: log this
              raise if retries >= max_retries
              retries += 1
              sleep 1.0
            end
          end
        end
      end
    end
  end
end
