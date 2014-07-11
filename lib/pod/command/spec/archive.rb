module Pod
  class Command
    class Lib
      # This is an example of a cocoapods plugin adding a subcommand to
      # the 'pod spec' command. Adapt it to suit your needs.
      #
      # @todo Create a PR to add your plugin to CocoaPods/cocoapods.org
      #       in the `plugins.json` file, once your plugin is released.
      #
      class Archive < Lib
        self.summary = "Archives your pod in as a static library."

        self.description = <<-DESC
          Longer description of cocoapods-archive.
        DESC

        def initialize(argv)
          @name = argv.shift_argument
          super
        end

        def validate!
          super
          help! "A Pod name is required." unless @name
        end

        def run
          UI.puts "Hello, world"
        end
      end
    end
  end
end
