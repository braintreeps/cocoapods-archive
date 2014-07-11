module Pod
  class Command
    class Lib
      class Archive < Lib
        self.summary = "Archives your pod in as a static library."

        self.description = <<-DESC
          Longer description of cocoapods-archive.
        DESC

        def initialize(argv)
          @name = argv.shift_argument
          @output = "./output"
          super
        end

        def validate!
          super
          help! "A Pod name is required." unless @name
        end

        def run
          UI.puts "Archiving #{@name}"

          spec = Specification.from_file(@name)
          UI.puts spec


          sandbox = Sandbox.new("/tmp/CocoaPods/Archive")
          project = Xcodeproj::Project.new(sandbox.project_path)
          project.save

          podfile = Podfile.from_hash({"target_definitions"=>[{"name"=>"Pods", "platform" => { "ios" => "7.1" }, "link_with_first_target"=>true, "user_project_path"=> sandbox.project_path, "dependencies"=>[{"Braintree"=>[{:path=>"/Users/pair/bt/braintree-ios"}]}]}]})

          config.integrate_targets = false
          installer = Installer.new(sandbox, podfile)
          installer.update = false
          installer.install!
        end
      end
    end
  end
end
