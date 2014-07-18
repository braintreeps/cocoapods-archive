require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$:.unshift((ROOT + 'lib').to_s)
$:.unshift((ROOT + 'spec').to_s)

require 'ostruct'
require 'bundler/setup'
require 'rspec'
require 'cocoapods'

require 'cocoapods_plugin'

module Pod
  # Disable the wrapping so the output is deterministic in the tests.
  #
  UI.disable_wrap = true

  # Redirects the messages to an internal store.
  #
  module UI
    @output = ''
    @warnings = ''

    class << self
      attr_accessor :output
      attr_accessor :warnings

      def puts(message = '')
        @output << "#{message}\n"
      end

      def warn(message = '', actions = [])
        @warnings << "#{message}\n"
      end

      def print(message)
        @output << message
      end
    end
  end
end

module SpecHelper
  module Command
    def argv(*argv)
      CLAide::ARGV.new(argv)
    end

    def command(*argv)
      argv << '--no-ansi'
      Pod::Command.parse(argv)
    end

    def run_command(*args)
      cmd = command(*args)
      cmd.validate!
      cmd.run
      Pod::UI.output
    end
  end

  module Fixture
    def self.default
      OpenStruct.new(
        name: "AFNetworking",
        version: "2.3.1",
        path: "spec/fixtures/AFNetworking",
      )
    end
  end
end
