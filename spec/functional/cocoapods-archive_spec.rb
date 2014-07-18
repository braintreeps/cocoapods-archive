require 'spec_helper'
require 'tmpdir'

module Pod
  describe Command::Lib::Archive do
    include SpecHelper::Command

    it 'registers itself' do
      expect(Command.parse(%w{ lib archive })).to be_instance_of(Command::Lib::Archive)
    end

    it 'shows help if no podspec is specified' do
      expect { run_command('lib', 'archive') }.to raise_error(CLAide::Help)
    end

    it 'shows help if --help is specified' do
      expect { run_command('lib', 'archive', '--help') }.to raise_error(CLAide::Help)
    end

    it 'shows an error if there is no podspec in the current working directory' do
      Dir.mktmpdir do |empty_working_directory|
        Dir.chdir(empty_working_directory) do
          expect { run_command('lib', 'archive') }.to raise_error(CLAide::Help) { |error| expect(error.error_message).to eq('Unable to find a podspec in the working directory') }
        end
      end
    end

    it 'archives the specified Pod to the default destination' do
      Dir.mktmpdir do |destination|
        stub_const('Pod::Command::Lib::Archive::BUILD_ROOT', Pathname.new(destination))
        Dir.chdir(SpecHelper::Fixture.default.path) do

          run_command('lib', 'archive')

          name = SpecHelper::Fixture.default.name
          name_with_version = "#{name}-#{SpecHelper::Fixture.default.version}"

          expect(Pathname.new(destination).entries.map(&:to_path)).to include("#{name_with_version}", "#{name_with_version}.tar.gz", "#{name_with_version}.zip")

          @destination = destination
          expect(Pathname.new(destination) + name_with_version + "lib#{name}.a").to exist
        end
      end
    end
  end
end
