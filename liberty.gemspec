# frozen_string_literal: true

require_relative "lib/liberty/version"

Gem::Specification.new do |spec|
  spec.name = "liberty"
  spec.version = Liberty::VERSION
  spec.authors = ["Alan Ridlehoover", "Fito von Zastrow"]
  spec.email = ["liberty@firsttry.software"]

  spec.summary = "A framework for Ruby web applications"
  spec.description = "Liberty is the state of being free from oppressive restrictions imposed by authority."
  spec.homepage = "https://github.com/first-try-software/liberty"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/first-try-software/liberty/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json", "~> 2.3"
  spec.add_dependency "mustermann", "~> 4.0"
  spec.add_dependency "mustermann-contrib", "~> 4.0"
  spec.add_dependency "rack", "~> 3.1"
  spec.add_dependency "rack-abstract-format", "~> 0.9.9"
  spec.add_dependency "rack-accept-media-types", "~> 0.9"
end
