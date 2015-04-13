module Crabfarm

  class Configuration

    class Option < Struct.new(:name, :type, :text); end

    OPTIONS = [
      [:driver, ['chrome', 'firefox', 'phantomjs', 'remote'], 'Browser driver to be used, common options: phantomjs, chrome, firefox, remote.'],
      [:parser_engine, :string, 'Default parser engine used by parsers'],
      [:output_builder, :string, 'Default json output builder used by states'],
      [:log_path, :string, 'Path where logs should be stored'],
      [:proxy, :string, 'If given, a proxy is used to connect to the internet if driver supports it'],

      # Webdriver configuration parameters
      [:driver_host, :string, 'Remote host, only available in driver: remote'],
      [:driver_port, :integer, 'Remote port, only available in driver: remote'],
      [:driver_capabilities, :mixed, 'Driver capabilities, depends on selected driver.'],
      [:driver_remote_timeout, :float, 'Request timeout in seconds, only available for remote or phatomjs driver.'],
      [:driver_window_width, :integer, 'Initial browser window width.'],
      [:driver_window_height, :integer, 'Initial browser window height.'],
      [:webdriver_dsl, :string, 'Webdriver wrapper to use, built in options are watir and surfer'],

      # Phantom launcher configuration
      [:phantom_load_images, :boolean, 'Phantomjs image loading, only for phantomjs driver.'],
      [:phantom_ssl, ['sslv3', 'sslv2', 'tlsv1', 'any'], 'Phantomjs ssl mode: sslv3, sslv2, tlsv1 or any, only for phantomjs driver.'],
      [:phantom_bin_path, :string, 'Phantomjs binary path, only for phantomjs driver.'],

      # Crabtrap launcher configuration
      [:crabtrap_bin_path, :string, 'Crabtrap binary path.'],

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
        parser_engine: :nokogiri,
        output_builder: :hash,
        driver_factory: nil,
        log_path: nil,
        proxy: nil,
        driver: 'phantomjs',
        driver_capabilities: nil,
        driver_host: 'localhost',
        driver_port: '8080',
        driver_remote_timeout: 120,
        driver_window_width: 1280,
        driver_window_height: 800,
        webdriver_dsl: :surfer,
        phantom_load_images: false,
        phantom_ssl: 'any',
        phantom_bin_path: 'phantomjs',
        crabtrap_bin_path: 'crabtrap',
        recorder_driver: :firefox
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

    def crabtrap_config
      {
        bin_path: crabtrap_bin_path,
        proxy: proxy
      }
    end

    # Add enviroment support (like a Gemfile)
    # group :test { set_driver :phantom }
    # set_driver :phantom, group: :test

  end

end
