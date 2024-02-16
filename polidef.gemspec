# frozen_string_literal: true

require_relative "lib/polidef/version"

Gem::Specification.new do |spec|
  spec.name = "polidef"
  spec.version = Polidef::VERSION
  spec.license = "MIT"

  spec.authors = ["JD Gonzales"]
  spec.email = ["jd_gonzales@icloud.com"]

  spec.summary = "Useful abstractions to manage complex conditionals."
  spec.description = <<~TEXT
    Polidef is a convience API for managing complex and potentially stateful conditionals through policy objects.
    Complex conditionals are fragile and can require a lot of state to exist in order to execute as expected. Polidef
    seeks to simplify implementation and testing so you spend less time wrangling conditional state and more time
    doing other things.
  TEXT

  spec.homepage = "https://github.com/juliusdelta/polidef"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6.0"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "standard", "~> 1.31.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
