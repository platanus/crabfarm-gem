require 'yaml'
require 'git'
require 'zlib'
require 'rubygems/package'
require 'net/http/post/multipart'
require 'rainbow'
require 'rainbow/ext/string'
require 'digest/sha1'

module Crabfarm
  module Modes
    module Publisher
      extend self

      DEFAULT_HOST = 'http://www.crabfarm.io'

      def publish(_path, _options={})

        @crawler_path = _path

        load_config
        detect_git_repo

        if inside_git_repo?
          if not _options.fetch(:unsafe, false) and is_tree_dirty?
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

        send_package unless _options.fetch(:dry, false)
      end

    private

      def load_config
        config = YAML.load_file File.join(@crawler_path, '.crabfarm')
        @name = config['name']
        @host = config['host'] || DEFAULT_HOST
        @include = config['files']
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
        url = URI.join(@host, 'api/crawlers/', @name)

        req = Net::HTTP::Put::Multipart.new(url.path, {
          "repo" => UploadIO.new(StringIO.new(@cpackage.string), "application/x-gzip", "tree.tar.gz"),
          "sha" => @signature,
          "ref" => @ref
        })

        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end

        puts res.body
      end

    end
  end
end