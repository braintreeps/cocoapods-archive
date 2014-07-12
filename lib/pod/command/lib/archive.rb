require 'pry'
module Pod
  class Command
    class Lib
      class Archive < Lib
        BUILD_ROOT = "/tmp/CocoaPods/Archive"

        self.summary = "Archives your pod in as a static library."

        self.description = <<-DESC
          Creates an archive containing everything one would need to integrate this CocoaPod without using CocoaPods:

          * A `.a` static library
          * A number of public `.h` headers
          * An `.xcconfig` file with the appropriate integration configuration settings
          * A README with integration instructions

          This tool is useful if your primary distribution mechanism is CocoaPods but a significat portion of your userbase does not yet use dependency management. Instead, they get a closed-source version with manual integration instructions.
        DESC

        def initialize(argv)
          @name = argv.shift_argument
          @output = "lib#{@name.capitalize}.a"
          super
        end

        def validate!
          super
          help! "A Pod name is required." unless @name
        end

        def run
          UI.puts "Archiving #{@name}"

          create_spec
          create_sandbox
          create_project
          create_podfile
          create_installer
          @installer.install!
          create_scheme
          build_project
        end

        def create_spec
          spec = Specification.from_file(@name)
          UI.puts spec
          @spec = spec
        end


        def create_sandbox
          @sandbox = Sandbox.new(BUILD_ROOT)
        end

        def create_project
          @project = Xcodeproj::Project.new(@sandbox.project_path)
          @project.save
          @project
        end

        def create_podfile
          podfile = {
            "target_definitions" => [{
              "name"=> @name,
              "platform" => { "ios" => "7.1" },
              "link_with_first_target"=>true,
              "user_project_path"=> @sandbox.project_path,
              "dependencies"=> [{ "Braintree" => [ {:path=>"/Users/pair/bt/braintree-ios" } ] }]
            }]
          }
          @podfile = Podfile.from_hash(podfile)
        end

        def create_installer
          config.integrate_targets = false
          @installer = Installer.new(@sandbox, @podfile)
          @installer.update = false
          @installer
        end

        def create_scheme
          @scheme = Xcodeproj::XCScheme.new
          @scheme.add_build_target(@installer.aggregate_targets.first.target, true)
          @scheme.save_as(@sandbox.project_path, "Archive", true)
        end

        def build_project
          UI.puts %x{cd #{BUILD_ROOT} && xcodebuild -sdk iphoneos && xcodebuild -sdk iphonesimulator && lipo -create build/Release-iphoneos/libPods.a build/Release-iphonesimulator/libPods.a -output #{@output}}
          UI.puts "built .a file at #{@output}"
          require 'pry';binding.pry
        end
      end
    end
  end
end
