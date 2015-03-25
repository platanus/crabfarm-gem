require 'spec_helper'
require 'watir-webdriver'
require 'crabfarm/modes/generator'

TEMPLATE_DIR = File.expand_path('../../../../lib/crabfarm/templates', __FILE__)
TEMPLATE_CACHE = Hash[
  [
    'dot_gitignore',
    'Gemfile',
    'Crabfile',
    'dot_rspec',
    'dot_crabfarm',
    'boot.rb',
    'crabfarm_bin',
    'dot_gitkeep',
    'spec_helper.rb',
    'state.rb',
    'state_spec.rb',
    'parser.rb',
    'parser_spec.rb'
  ].map do |file|
    path = File.join(TEMPLATE_DIR, file) + '.erb'
    [ path, File.read(path) ]
  end
]

describe Crabfarm::Modes::Generator do
  include FakeFS::SpecHelpers

  before {
    # move template files to fake fs
    FileUtils.mkdir_p TEMPLATE_DIR
    TEMPLATE_CACHE.keys.each { |k| File.open(k, 'w') { |f| f.write TEMPLATE_CACHE[k] } }
  }

  describe "generate_app" do

    context "when a remote is given" do

      before { Crabfarm::Modes::Generator.generate_app(Dir.pwd, 'test_app', 'platanus/demo') }

      it "should generate a .crabfarm file" do
        path = File.join('test_app', '.crabfarm')
        expect(File.exist? path).to be_truthy
        expect(File.read path).to eq(
<<-eos
host: http://api.crabfarm.io
remote: platanus/demo
files:
- Crabfile
- Gemfile
- Gemfile.lock
- boot.rb
- app/**/*.*
- bin/**/*.*
eos
        )
      end

      it "should generate a Crabfile file" do
        expect(File.exist? File.join('test_app', 'Crabfile')).to be_truthy
      end

      it "should generate required folders" do
        expect(File.exist? File.join('test_app', 'app/parsers')).to be_truthy
        expect(File.exist? File.join('test_app', 'app/states')).to be_truthy
        expect(File.exist? File.join('test_app', 'app/helpers')).to be_truthy
        expect(File.exist? File.join('test_app', 'spec/mementos')).to be_truthy
        expect(File.exist? File.join('test_app', 'spec/snapshots')).to be_truthy
        expect(File.exist? File.join('test_app', 'spec/integration')).to be_truthy
      end

    end

    context "when no remote is given" do

      before { Crabfarm::Modes::Generator.generate_app(Dir.pwd, 'test_app') }

      it "should generate a .crabfarm file" do
        path = File.join('test_app', '.crabfarm')
        expect(File.exist? path).to be_truthy
        expect(File.read path).to eq(
<<-eos
host: http://api.crabfarm.io

files:
- Crabfile
- Gemfile
- Gemfile.lock
- boot.rb
- app/**/*.*
- bin/**/*.*
eos
        )
      end

    end

  end

  describe "generate_parser" do

    context "if run after app generator" do

      before { Crabfarm::Modes::Generator.generate_app(Dir.pwd, 'test_app') }

      it "should generate required files" do
        Crabfarm::Modes::Generator.generate_parser(File.join(Dir.pwd, 'test_app'), 'MyTable')

        expect(File.exist? File.join('test_app', 'app/parsers/my_table_parser.rb')).to be_truthy
        expect(File.exist? File.join('test_app', 'spec/parsers/my_table_parser_spec.rb')).to be_truthy
      end

    end
  end

  describe "generate_state" do

    context "if run after app generator" do

      before { Crabfarm::Modes::Generator.generate_app(Dir.pwd, 'test_app') }

      it "should generate required files" do
        Crabfarm::Modes::Generator.generate_state(File.join(Dir.pwd, 'test_app'), 'MyPage')

        expect(File.exist? File.join('test_app', 'app/states/my_page.rb')).to be_truthy
        expect(File.exist? File.join('test_app', 'spec/states/my_page_spec.rb')).to be_truthy
      end

    end
  end

end
