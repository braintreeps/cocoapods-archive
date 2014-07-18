require 'camelizable/string'

using Camelizable

describe Camelizable do
  describe '#camelize' do
    it 'should camlelize a string' do
        expect('FooBar'.camelize).to eq('FooBar')
        expect('foo bar'.camelize).to eq('FooBar')
        expect('foo-bar'.camelize).to eq('FooBar')
        expect('foo_bar'.camelize).to eq('FooBar')
        expect('Foo bar'.camelize).to eq('FooBar')
        expect('foo Bar'.camelize).to eq('FooBar')
    end
  end
end
