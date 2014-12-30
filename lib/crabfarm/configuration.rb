module Crabfarm

  class Configuration

    # TODO: improve DSL, it sucks

    attr_accessor :default_dsl
    attr_accessor :driver_factory

    # Default driver configuration parameters
    attr_accessor :driver_name
    attr_accessor :driver_host
    attr_accessor :driver_port
    attr_accessor :driver_capabilities
    attr_accessor :driver_remote_timeout
    attr_accessor :driver_window_width
    attr_accessor :driver_window_height

    # Phantom launcher configuration
    attr_accessor :phantom_enabled
    attr_accessor :phantom_load_images
    attr_accessor :phantom_proxy
    attr_accessor :phantom_ssl
    attr_accessor :phantom_bin_path
    attr_accessor :phantom_lock_file

    def driver_config
      {
        name: @driver_name,
        capabilities: @driver_capabilities,
        remote_host: driver_remote_host,
        remote_timeout: @driver_remote_timeout,
        window_width: @driver_window_width,
        window_height: @driver_window_height
      }
    end

    def phantom_enabled?
      @phantom_enabled
    end

    def phantom_config
      {
        load_images: @phantom_load_images,
        proxy: @phantom_proxy,
        ssl: @phantom_ssl,
        bin_path: @phantom_bin_path,
        lock_file: @phantom_lock_file
      }
    end

    def initialize
      @default_dsl = :surfer
      @driver_factory = nil

      @driver_name = :chrome
      @driver_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      @driver_host = 'localhost'
      @driver_port = '8080'
      @driver_remote_timeout = 120
      @driver_window_width = 1280
      @driver_window_height = 800

      @phantom_enabled = false
      @phantom_load_images = false
      @phantom_proxy = nil
      @phantom_ssl = 'any'
      @phantom_bin_path = 'phantomjs'
      @phantom_lock_file = nil
    end

  private

    def driver_remote_host
      if @driver_host.nil? then nil
      elsif @driver_port.nil? then "http://#{@driver_host}"
      else "http://#{@driver_host}:#{@driver_port}"
      end
    end

  end

end
