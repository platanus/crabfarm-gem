module Crabfarm
  class PhantomDriverFactory

    def initialize(_phantom, _config={})
      @phantom = _phantom
      @config = _config
    end

    def build_driver(_session_id)

      # setup a custom client to use longer timeouts
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = @config[:remote_timeout]

      driver = Selenium::WebDriver.for :remote, {
        :url => phantom_url,
        :http_client => client,
        :desired_capabilities => @config[:capabilities]
      }

      driver.send(:bridge).setWindowSize(@config[:window_width], @config[:window_height])

      return driver
    end

  private

    def phantom_url
      "http://localhost:#{@phantom.port}"
    end

  end
end
