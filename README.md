cocoapods-archive
=================

A CocoaPods plugin that archives your pod into a .a file for distribution

This plugin is for CocoaPods *developers*, who need to distribute their Pods not only as CocoaPods, but also as static libraries. Some users just like it the good old fashioned way.

![Demo](CocoaPods-Archive-Demo.gif)

There are still a number of advantages to developing against a `podspec`, even if your public distribution is closed-source:

1. You can easily use the Pod in-house open-source, which makes step-by-step debugging a breeze.
2. You can pull in third-party dependencies using CocoaPods. (Note: Your static library could cause linker errors in certain projects, where duplicate symbols are present due to common dependencies.)
3. You can declaratively specify build settings (e.g. frameworks, compiler flags) in your `podspec`. This is easier to keep track of than build settings embedded in your Xcode project.

## Installation

```sh
$ gem install cocoapods-archive
```

or add a line to your Gemfile:

```ruby
gem "cocoapods-archive"
```

then run `bundle install`.

## Usage

```sh
$ cd YOUR_POD && pod lib archive
```

See also `pod lib archive --help`.
