module Crabfarm

  class Configuration

    class Option < Struct.new(:name, :type, :text); end

    OPTIONS = [
      # Global options
      [:browser, ['chrome', 'firefox', 'phantomjs', 'remote', 'chenso'], 'Browser engine to be used by navigators, common options: phantomjs, chrome, firefox, remote.'],
      [:parser, :string, 'Default parser engine used by reducers'],
      [:log_path, :string, 'Path where logs should be stored'],
      [:proxy, :string, 'If given, a proxy is used to connect to the internet if driver supports it'],
      [:proxy_auth, :string, 'Proxy authentication parameters as user:password'],
      [:user_agent, :string, 'Allows overriding default driver user agent, only available in chenso'],

      # Webdriver configuration parameters
      [:webdriver_host, :string, 'Remote host, only available in driver: remote'],
      [:webdriver_port, :integer, 'Remote port, only available in driver: remote'],
      [:webdriver_capabilities, :mixed, 'Driver capabilities, depends on selected driver.'],
      [:webdriver_remote_timeout, :float, 'Request timeout in seconds, only available for remote or phantomjs driver.'],
      [:webdriver_window_width, :integer, 'Initial browser window width.'],
      [:webdriver_window_height, :integer, 'Initial browser window height.'],
      [:webdriver_dsl, :string, 'Webdriver wrapper to use, built in options are pincers and watir'],

      # Phantom launcher configuration
      [:phantom_load_images, :boolean, 'Phantomjs image loading, only for phantomjs driver.'],
      [:phantom_log_level, ['error', 'warn', 'info', 'debug'], 'Phantomjs log level.'],
      [:phantom_ssl, ['sslv3', 'sslv2', 'tlsv1', 'any'], 'Phantomjs ssl mode: sslv3, sslv2, tlsv1 or any, only for phantomjs driver.'],
      [:phantom_bin_path, :string, 'Phantomjs binary path, only for phantomjs driver.'],

      # Crabtrap launcher configuration
      [:crabtrap_bin_path, :string, 'Crabtrap binary path.'],
      [:crabtrap_log_level, ['error', 'warn', 'info', 'debug'], 'Crabtrap log level'],

      # Recorder configuration
      [:recorder_driver, :string, 'Recorder driver name, defaults to \'firefox\'']
    ]
    .map { |o| Option.new(*o) }

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
        browser: 'phantomjs',
        parser: :pincers,
        driver_factory: nil,
        log_path: nil,
        proxy: nil,
        proxy_auth: nil,
        user_agent: nil,
        webdriver_capabilities: nil,
        webdriver_host: 'localhost',
        webdriver_port: '8080',
        webdriver_remote_timeout: 120,
        webdriver_window_width: 1280,
        webdriver_window_height: 800,
        webdriver_dsl: :pincers,
        phantom_load_images: false,
        phantom_ssl: 'any',
        phantom_bin_path: 'phantomjs',
        phantom_log_level: :warn,
        crabtrap_bin_path: 'crabtrap',
        crabtrap_log_level: :warn,
        recorder_driver: :firefox
      }
    end

    def set(_options)
      @values.merge! _options
    end

    def webdriver_remote_host
      if webdriver_host then nil
      elsif webdriver_port then "http://#{webdriver_host}"
      else "http://#{webdriver_host}:#{webdriver_port}"
      end
    end

    def crabtrap_config
      {
        bin_path: crabtrap_bin_path,
        log_level: crabtrap_log_level
      }
    end

    # Add enviroment support (like a Gemfile)
    # group :test { set_driver :phantom }
    # set_driver :phantom, group: :test

  end

end
