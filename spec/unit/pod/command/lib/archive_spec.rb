require 'ostruct'
require 'pod/command/lib/archive'

module Pod
  describe Command::Lib::Archive do
    describe '#output_static_library' do
      it 'returns a static .a path name based on the spec name' do
        archive = Command::Lib::Archive.new(CLAide::ARGV.new(%w(some-pod)))

        allow(archive).to receive(:spec).and_return(OpenStruct.new(name: 'some-pod', version: '1.2.1'))

        expect(archive.output_static_library.to_s).to eq('/tmp/CocoaPods/Archive/some-pod-1.2.1/libSomePod.a')
      end
    end

    describe '#sandbox_pathname' do
      it 'returns a static .a path name based on the spec name' do
        archive = Command::Lib::Archive.new(CLAide::ARGV.new(%w(some-pod)))

        allow(archive).to receive(:spec).and_return(OpenStruct.new(name: 'some-pod'))

        expect(archive.sandbox_pathname.to_s).to eq('/tmp/CocoaPods/Archive/sandbox')
      end

      describe 'BUILD_ROOT' do
        it 'uses /tmp/CocoaPods/Archive as a default destination' do
          expect(Command::Lib::Archive::BUILD_ROOT.to_path).to eq('/tmp/CocoaPods/Archive')
        end
      end
    end
  end
end
