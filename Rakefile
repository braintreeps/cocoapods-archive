require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# Bootstrap task
#-----------------------------------------------------------------------------#

desc "Initializes your working copy to run the specs"
task :bootstrap, :use_bundle_dir? do |t, args|
  title "Environment bootstrap"

  puts "Updating submodules"
  execute_command "git submodule update --init --recursive"

  require 'rbconfig'
  if RbConfig::CONFIG['prefix'] == '/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr'
    # Workaround Apple's mess. See https://github.com/CocoaPods/Xcodeproj/issues/137
    #
    # TODO This is not as correct as actually fixing the issue, figure out if we
    # can override these build flags:
    #
    # ENV['DLDFLAGS'] = '-undefined dynamic_lookup -multiply_defined suppress'
    ENV['ARCHFLAGS'] = '-Wno-error=unused-command-line-argument-hard-error-in-future'
  end

  if system('which bundle')
    puts "Installing gems"
    if args[:use_bundle_dir?]
      execute_command "env XCODEPROJ_BUILD=1 bundle install --path ./travis_bundle_dir"
    else
      execute_command "env XCODEPROJ_BUILD=1 bundle install"
    end
  else
    $stderr.puts "\033[0;31m" \
      "[!] Please install the bundler gem manually:\n" \
      '    $ [sudo] gem install bundler' \
      "\e[0m"
    exit 1
  end
end

# Helpers
#-----------------------------------------------------------------------------#

def execute_command(command)
  if ENV['VERBOSE']
    sh(command)
  else
    output = `#{command} 2>&1`
    raise output unless $?.success?
  end
end

def gem_version
  require File.expand_path('../lib/cocoapods/gem_version.rb', __FILE__)
  Pod::VERSION
end

def title(title)
  cyan_title = "\033[0;36m#{title}\033[0m"
  puts
  puts "-" * 80
  puts cyan_title
  puts "-" * 80
  puts
end

def red(string)
  "\033[0;31m#{string}\e[0m"
end
