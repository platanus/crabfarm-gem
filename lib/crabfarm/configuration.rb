module Crabfarm

  class Configuration

    class Option < Struct.new(:name, :type, :text); end

    OPTIONS = [
      [:browser_dsl, :string, 'Default browser dsl used by parsers and states'],
      [:output_builder, :string, 'Default json output builder used by states'],
      [:driver_factory, :mixed, 'Driver factory, disabled if phantom_mode is used'],
      [:log_path, :string, 'Path where logs should be stored'],

      # Default driver configuration parameters
      [:driver, ['chrome', 'firefox', 'phantomjs', 'remote'], 'Webdriver to be user, common options: chrome, firefox, phantomjs, remote.'],
      [:driver_host, :string, 'Remote host, only available in driver: remote'],
      [:driver_port, :integer, 'Remote port, only available in driver: remote'],
      [:driver_capabilities, :mixed, 'Driver capabilities, depends on selected driver.'],
      [:driver_remote_timeout, :float, 'Request timeout in seconds, only available for remote or phatomjs driver.'],
      [:driver_window_width, :integer, 'Initial browser window width.'],
      [:driver_window_height, :integer, 'Initial browser window height.'],

      # Phantom launcher configuration
      [:phantom_load_images, :boolean, 'Phantomjs image loading, only for phantomjs driver.'],
      [:phantom_proxy, :string, 'Phantonjs proxy address, only for phantomjs driver.'],
      [:phantom_ssl, ['sslv3', 'sslv2', 'tlsv1', 'any'], 'Phantomjs ssl mode: sslv3, sslv2, tlsv1 or any, only for phantomjs driver.'],
      [:phantom_bin_path, :string, 'Phantomjs binary path, only for phantomjs driver.'],
      [:phantom_lock_file, :string, 'Phantomjs lock file path, only for phantomjs driver.']
    ]
    .map { |o| Option.new *o }

    OPTIONS.each do |var|
      define_method "set_#{var.name}" do |val|
        @values[var.name] = val
      end

      define_method "#{var.name}" do
        @values[var.name]
      end
    end

    def initialize
      reset
    end

    def reset
      @values = {
        browser_dsl: :surfer,
        output_builder: :hash,
        driver_factory: nil,
        log_path: 'logs',

        driver: 'phantomjs',
        driver_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox,
        driver_host: 'localhost',
        driver_port: '8080',
        driver_remote_timeout: 120,
        driver_window_width: 1280,
        driver_window_height: 800,

        phantom_load_images: false,
        phantom_proxy: nil,
        phantom_ssl: 'any',
        phantom_bin_path: 'phantomjs',
        phantom_lock_file: nil
      }
    end

    def set(_options)
      @values.merge! _options
    end

    def driver_remote_host
      if driver_host then nil
      elsif driver_port then "http://#{driver_host}"
      else "http://#{driver_host}:#{driver_port}"
      end
    end

    def driver_config
      {
        name: driver,
        capabilities: driver_capabilities,
        remote_host: driver_remote_host,
        remote_timeout: driver_remote_timeout,
        window_width: driver_window_width,
        window_height: driver_window_height
      }
    end

    def phantom_mode_enabled?
      driver.to_s == 'phantomjs'
    end

    def phantom_config
      {
        load_images: phantom_load_images,
        proxy: phantom_proxy,
        ssl: phantom_ssl,
        bin_path: phantom_bin_path,
        lock_file: phantom_lock_file,
        log_file: log_path ? File.join(log_path, 'phantom.log') : nil
      }
    end

     # Add enviroment support (like a Gemfile)
     # group :test { set_driver :phantom }
     # set_driver :phantom, group: :test

  end

end
