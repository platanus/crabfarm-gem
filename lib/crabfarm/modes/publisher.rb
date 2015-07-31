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

module Crabfarm
  module Modes
    module Publisher
      extend self

      DEFAULT_HOST = 'http://api.crabfarm.io'

      def publish(_path, _options={})

        @crawler_path = _path
        @options = _options

        load_config
        return unless dry_run or check_credentials
        detect_git_repo

        if inside_git_repo?
          if not unsafe and is_tree_dirty?
            puts "Aborting: Your working copy has uncommited changes! Use the --unsafe option to force.".color(:red)
            return
          end
          load_files_from_git
        else
          load_files_from_fs
        end

        build_package
        compress_package
        generate_signature

        send_package if not dry_run and ensure_valid_remote
      end

    private

      def dry_run
        @options.fetch(:dry, false)
      end

      def unsafe
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
          @url = Ask.input 'Enter default remote for crawler'
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
        puts "Invalid remote syntax: #{_url}".color :red
        return false
      end

      def check_credentials
        if @token.nil?
          puts 'No credential data found, please identify yourself'
          email = Ask.input 'Enter your crabfarm.io email'
          password = Ask.input 'Enter your crabfarm.io password'

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
            puts "The provided credentials are invalid!".color(:red)
          else
            puts "Unknown error when asking for token!".color(:red)
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
            return
          else
            path_to_git << File.basename(git_path)
            git_path = File.expand_path('..', git_path)
          end
        end

        @git = nil
      end

      def inside_git_repo?
        not @git.nil?
      end

      def load_files_from_git
        @git.chdir do
          @ref = @git.log.first.sha
          puts "Packaging files from current HEAD (#{@ref}):".color(:green)
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
        puts "Packaging files (no version control)".color(:green)
        @file_list = Dir[*@include].map do |path|
          full_path = File.join(@crawler_path, path)
          [path, File.stat(full_path).mode, File.read(full_path)]
        end
        @ref = "filesystem"
      end

      def build_package
        @package = StringIO.new("")
        Gem::Package::TarWriter.new(@package) do |tar|
          @file_list.each do |f|
            puts "+ #{f[0]} - #{f[1]}"
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
        puts "Package SHA1: #{@signature}"
      end

      def send_package
        resp = send_request(Net::HTTP::Put, "api/bots/#{@url}", {
          "repo" => Base64.encode64(@cpackage.string),
          "sha" => @signature,
          "ref" => @ref
        })

        case resp
        when Net::HTTPSuccess
          sha = JSON.parse(resp.body)['sha']
          puts "#{@url} updated!"
        when Net::HTTPUnauthorized
          puts "You are not authorized to update crawler: #{@url}".color(:red)
        when Net::HTTPNotFound
          puts "Crawler not found: #{@url}".color(:red)
        else
          puts "Unknown error when updating crawler information!".color(:red)
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

    end
  end
end