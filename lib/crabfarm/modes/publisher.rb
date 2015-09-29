require 'yaml'
require 'json'
require 'git'
require 'zlib'
require 'inquirer'
require 'rubygems/package'
require 'base64'
require 'rainbow'
require 'rainbow/ext/string'
require 'digest/sha1'
require 'net/http'
require 'crabfarm/utils/console'

module Crabfarm
  module Modes
    module Publisher
      extend self

      DEFAULT_HOST = 'http://api.crabfarm.io'

      def publish(_path, _options={})

        @crawler_path = _path
        @options = _options

        load_config
        return unless dry_run? or check_credentials

        if !unsafe? and detect_git_repo
          if is_tree_dirty?
            console.warning "Aborting: Your working copy has uncommited changes! Use the --unsafe option to force."
            return
          end
          load_files_from_git
        else
          load_files_from_fs
        end

        build_package
        compress_package
        generate_signature

        build_payload
        send_package if not dry_run? and ensure_valid_remote

        @payload
      end

    private

      def verbose?
        @options.fetch(:verbose, true)
      end

      def dry_run?
        @options.fetch(:dry, false)
      end

      def unsafe?
        @options.fetch(:unsafe, false)
      end

      def config_path
        File.join(@crawler_path, '.crabfarm')
      end

      def home_config_path
        File.join(Dir.home, '.crabfarm')
      end

      def load_config
        @local_config = YAML.load_file config_path

        @home_config = if File.exists? home_config_path
          YAML.load_file home_config_path
        else {} end

        config = @home_config.merge @local_config

        @token = config['token']
        @url = @options[:remote] || config['remote']
        @host = config['host'] || DEFAULT_HOST
        @include = config['files']
      end

      def ensure_valid_remote
        if @url.nil?
          @url = console.question 'Enter default remote for crawler'
          return false unless validate_remote @url
          @local_config['remote'] = @url
          save_local_config
          return true
        else
          validate_remote @url
        end
      end

      def validate_remote(_url)
        return true if /^[\w\-]+\/[\w\-]+$/i === _url
        console.error "Invalid remote syntax: #{_url}"
        return false
      end

      def check_credentials
        if @token.nil?
          console.info 'No credential data found, please identify yourself'
          email = console.question 'Enter your crabfarm.io email'
          password = console.question 'Enter your crabfarm.io password'

          resp = send_request Net::HTTP::Post, 'api/tokens', {
            'email' => email,
            'password' => password
          }

          case resp
          when Net::HTTPCreated
            @token = JSON.parse(resp.body)['token']
            @home_config['token'] = @token
            save_home_config
          when Net::HTTPUnauthorized
            console.error "The provided credentials are invalid!"
          else
            console.error "Unknown error when asking for token!"
          end
        end

        not @token.nil?
      end

      def save_local_config
        save_config config_path, @local_config
      end

      def save_home_config
        save_config home_config_path, @home_config
      end

      def save_config(_path, _config)
        data = YAML.dump _config
        data = data.split("\n", 2).last # remove first line to make it more readable
        File.open(_path, 'w') { |f| f.write data }
      end

      def is_tree_dirty?
        @git.chdir do
          status = @git.status
          (status.changed.count + status.added.count + status.deleted.count + status.untracked.count) > 0
        end
      end

      def detect_git_repo
        git_path = @crawler_path

        path_to_git = []
        while git_path != '/'
          if File.exists? File.join(git_path, '.git')
            @git = Git.open git_path
            @rel_path = if path_to_git.count > 0 then File.join(*path_to_git.reverse!) else nil end
            return true
          else
            path_to_git << File.basename(git_path)
            git_path = File.expand_path('..', git_path)
          end
        end

        @git = nil
        return false
      end

      def load_files_from_git
        @git.chdir do
          @ref = @git.log.first.sha
          console.result "Packaging files from current HEAD (#{@ref}):" if verbose?
          entries = @git.gtree(@ref).full_tree.map(&:split)
          entries = entries.select { |e| e[1] == 'blob' }

          @file_list = []
          entries.each do |entry|
            path = unless @rel_path.nil?
              next unless entry[3].starts_with? @rel_path
              entry[3][@rel_path.length+1..-1]
            else entry[3] end

            if @include.any? { |p| File.fnmatch? p, path }
              @file_list << [path, entry[0].to_i(8), @git.show(@ref, entry[3])]
            end
          end
        end
      end

      def load_files_from_fs
        console.result "Packaging files (no version control)" if verbose?
        Dir.chdir(@crawler_path) do
          @file_list = Dir[*@include].map do |path|
            full_path = File.join(@crawler_path, path)
            [path, File.stat(full_path).mode, File.read(full_path)]
          end
        end
        @ref = "filesystem"
      end

      def build_package
        @package = StringIO.new("")
        Gem::Package::TarWriter.new(@package) do |tar|
          @file_list.each do |f|
            console.info "+ #{f[0]} - #{f[1]}" if verbose?
            path, mode, contents = f
            tar.add_file(path, mode) { |tf| tf.write contents }
          end
        end

        @package.rewind
      end

      def compress_package
        @cpackage = StringIO.new("")
        writer = Zlib::GzipWriter.new(@cpackage)
        writer.write @package.string
        writer.close
      end

      def generate_signature
        @signature = Digest::SHA1.hexdigest @package.string
        console.info "Package SHA1: #{@signature}" if verbose?
      end

      def build_payload
        @payload = {
          "repo" => Base64.encode64(@cpackage.string),
          "sha" => @signature,
          "ref" => @ref
        }
      end

      def send_package
        resp = send_request(Net::HTTP::Put, "api/bots/#{@url}", @payload)

        case resp
        when Net::HTTPSuccess
          sha = JSON.parse(resp.body)['sha']
          console.result "#{@url} updated!"
        when Net::HTTPUnauthorized
          console.error "You are not authorized to update crawler: #{@url}"
        when Net::HTTPNotFound
          console.error "Crawler not found: #{@url}"
        else
          console.error "Unknown error when updating crawler information!"
        end
      end

      def send_request(_class, _path, _data=nil)
        uri = URI.join(@host, _path)

        req = req = _class.new uri.path
        req.set_form_data _data
        req['X-User-Token'] = @token unless @token.nil?

        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end
      end

      def console
        Crabfarm::Utils::Console
      end

    end
  end
end