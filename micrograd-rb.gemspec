# frozen_string_literal: true

require_relative "lib/micrograd/version"

Gem::Specification.new do |spec|
  spec.name = "micrograd-rb"
  spec.version = Micrograd::VERSION
  spec.authors = ["Sean Collins"]
  spec.email = ["sean@cllns.com"]

  spec.summary = "Ruby implementation of micrograd"
  spec.homepage = "https://github.com/cllns/micrograd-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]
end
