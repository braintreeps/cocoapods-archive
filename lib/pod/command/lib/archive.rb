require 'pathname'
require 'fileutils'
require 'camelizable/string'
require 'cocoapods'

module Pod
  class Command
    class Lib
      class Archive < Lib
        using Camelizable
        BUILD_ROOT = Pathname.new("/tmp/CocoaPods/Archive")

        self.summary = "Archives your Pod as a static library"

        self.description = <<-DESC
          Creates an archive containing everything one would need to integrate the CocoaPod in the current working directory without using CocoaPods:

          - A `.a` static library

          - A number of public `.h` headers

          - An `.xcconfig` file with the appropriate integration configuration settings

          - A README with integration instructions

          This tool is useful if your primary distribution mechanism is CocoaPods but a significat portion of your userbase does not yet use dependency management. Instead, they receive a closed-source version with manual integration instructions.
        DESC

        self.arguments = [
          CLAide::Argument.new("[NAME]", :optional)
        ]

        attr_accessor :spec

        def initialize(argv)
          @podspec_pathname = argv.shift_argument || Pathname.glob(Pathname.pwd + '*.podspec').first
          super
        end

        def validate!
          super
          help! "Unable to find a podspec in the working directory" unless @podspec_pathname.try(:exist?)
        end

        def run
          create_spec

          UI.puts "Archiving #{spec.name} into #{BUILD_ROOT.to_s}"

          create_sandbox
          create_project
          create_podfile
          create_installer
          @installer.install!
          create_scheme
          build_project
          generate_readme
          compress_project

          UI.notice "Check #{output_pathname} for the compiled version of #{@spec.name}."
          UI.notice "All Done 📬"
        end

        def create_spec
          self.spec = Specification.from_file(@podspec_pathname)
        end

        def create_sandbox
          FileUtils.rm_rf BUILD_ROOT if BUILD_ROOT.exist?
          BUILD_ROOT.mkdir unless BUILD_ROOT.exist?
          sandbox_pathname.mkdir
          @sandbox = Sandbox.new(sandbox_pathname.to_s)
        end

        def create_project
          @project = Xcodeproj::Project.new(@sandbox.project_path)
          @project.save
          @project
        end

        def create_podfile
          podfile = {
            "target_definitions" => [{
            "name"=> spec.name,
            "platform" => { "ios" => "7.1" },
            "link_with_first_target" => true,
            "user_project_path" => @sandbox.project_path,
            "dependencies"=> [{ spec.name => [ { :path => @podspec_pathname.to_s } ] }]
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
          output_pathname.mkdir

          UI.message %x{cd #{@sandbox.root} && xcodebuild -sdk iphoneos && xcodebuild -sdk iphonesimulator}
          platform_specific_static_libraries = Pathname.glob(@sandbox.root + "build" + "Release-*" + "**" + @installer.aggregate_targets.first.product_name)
          UI.message %x{lipo -create #{platform_specific_static_libraries.join(" ")} -output #{output_static_library}}
          UI.puts "Built static library file in #{output_pathname}"

          headers = Pathname.glob(@spec.consumer(:ios).public_header_files)
          headers.each do |header_pathname|
            FileUtils.cp(header_pathname, output_pathname)
          end

          FileUtils.cp((sandbox_pathname + @installer.aggregate_targets.first.acknowledgements_basepath).to_path + ".markdown", output_pathname)
          FileUtils.cp((sandbox_pathname + @installer.aggregate_targets.first.acknowledgements_basepath).to_path + ".plist", output_pathname)

          FileUtils.cp((sandbox_pathname + @installer.aggregate_targets.first.xcconfig_path), output_pathname)
        end

        def generate_readme
          readme = <<-EOF
# #{@spec.to_s}

This directory contains the [#{@spec.name}](#{@spec.homepage}) Pod compiled as a static library. Although CocoaPods is the recommended integration technique, you can use this package to vendor the library in your project statically.

## Manual Integration Instructions

1. Drag this folder into your Xcode Project.
2. Check the box next to your app's name under "Add to targets".
3. You may need to tweak your build settings, adding libraries, frameworks and custom build settings.
          EOF

          if @spec.consumer(:ios).frameworks.count > 0
          readme << <<-EOF

  * Add these frameworks:

```
#{@spec.consumer(:ios).frameworks.join("\n")}
```
          EOF
          end

          if @spec.consumer(:ios).frameworks.count > 0
            readme << <<-EOF

            * Add these libraries:

          ```
          #{@spec.consumer(:ios).libraries.join("\n")}
          ```
          EOF
          end

          if @spec.consumer(:ios).xcconfig.count > 0
            readme << <<-EOF

  * Add these build settings:

```
#{@spec.consumer(:ios).xcconfig}
```
          EOF
          end

          readme << <<-EOF

## CocoaPods Integration

If you'd like to use CocoaPods afterall, add this line to your `Podfile`:

```ruby
pod "#{@spec.name}"
```

## Note

This folder and README were generated by CocoaPods-Archive.
          EOF

          readme.strip!

          (output_pathname + "README.md").write(readme)
        end

        def compress_project
          UI.puts "Creating compressed archives"
          UI.message %x{tar -cvzf "#{output_pathname.to_path + ".tar.gz"}" "#{output_pathname}" 2>&1}
          UI.message %x{zip -r "#{output_pathname.to_path + ".zip"}" "#{output_pathname}" 2>&1}
        end

        def output_pathname
          BUILD_ROOT + "#{spec.name}-#{spec.version}"
        end

        def sandbox_pathname
          BUILD_ROOT + "sandbox"
        end

        def output_static_library
          output_pathname + "lib#{spec.name.camelize}.a"
        end
      end
    end
  end
end
