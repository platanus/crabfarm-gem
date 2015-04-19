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
    'navigator.rb',
    'navigator_spec.rb',
    'reducer.rb',
    'reducer_spec.rb',
    'struct.rb'
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
- bin/*
eos
        )
      end

      it "should generate a Crabfile file" do
        expect(File.exist? File.join('test_app', 'Crabfile')).to be_truthy
      end

      it "should generate required folders" do
        expect(File.exist? File.join('test_app', 'app/reducers')).to be_truthy
        expect(File.exist? File.join('test_app', 'app/navigators')).to be_truthy
        expect(File.exist? File.join('test_app', 'app/structs')).to be_truthy
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
- bin/*
eos
        )
      end

    end

  end

  context "when inside a generated app" do

    before { Crabfarm::Modes::Generator.generate_app(Dir.pwd, 'test_app') }
    let(:app_path) { File.join(Dir.pwd, 'test_app') }

    describe "generate_reducer" do

      it "should generate required files" do
        Crabfarm::Modes::Generator.generate_reducer(app_path, 'MyTable')

        expect(File.exist? File.join(app_path, 'app/reducers/my_table_reducer.rb')).to be_truthy
        expect(File.exist? File.join(app_path, 'spec/reducers/my_table_reducer_spec.rb')).to be_truthy
      end

      it "should fail is invalid class name is given" do
        expect { Crabfarm::Modes::Generator.generate_reducer(app_path, 'my_table') }.to raise_error Crabfarm::ArgumentError
      end

      it "should generate nested folders if a namespaced class is provided" do
        Crabfarm::Modes::Generator.generate_reducer(app_path, 'Platanus::Objects::MyTable')

        expect(File.exist? File.join(app_path, 'app/reducers/platanus/objects/my_table_reducer.rb')).to be_truthy
        expect(File.exist? File.join(app_path, 'spec/reducers/platanus/objects/my_table_reducer_spec.rb')).to be_truthy
      end

    end

    describe "generate_navigator" do

      it "should generate required files" do
        Crabfarm::Modes::Generator.generate_navigator(app_path, 'MyPage')

        expect(File.exist? File.join(app_path, 'app/navigators/my_page.rb')).to be_truthy
        expect(File.exist? File.join(app_path, 'spec/navigators/my_page_spec.rb')).to be_truthy
      end

      it "should generate navigator source file referencing url if given" do
        Crabfarm::Modes::Generator.generate_navigator(app_path, 'MyPage', url: 'www.crabfarm.io')

        expect(File.read File.join(app_path, 'app/navigators/my_page.rb')).to include('www.crabfarm.io')
      end

    end

    describe "generate_struct" do

      it "should generate required files" do
        Crabfarm::Modes::Generator.generate_struct(app_path, 'MyData')

        expect(File.exist? File.join(app_path, 'app/structs/my_data.rb')).to be_truthy
      end

    end
  end
end
