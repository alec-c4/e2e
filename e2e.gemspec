# frozen_string_literal: true

require_relative "lib/e2e/version"

Gem::Specification.new do |spec|
  spec.name = "e2e"
  spec.version = E2E::VERSION
  spec.authors = ["Alexey Poimtsev"]
  spec.email = ["alexey.poimtsev@gmail.com"]

  spec.summary = "Unified E2E testing framework for Ruby."
  spec.description = "A flexible E2E testing library allowing pluggable drivers (starting with Playwright) with a clean, unified API."
  spec.homepage = "https://github.com/alec-c4/e2e"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alec-c4/e2e"
  spec.metadata["changelog_uri"] = "https://github.com/alec-c4/e2e/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "playwright-ruby-client", ">= 1.40.0"
  spec.add_dependency "rack"
  spec.add_dependency "rackup"
  spec.add_dependency "webrick"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "lefthook"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "standard"
end
