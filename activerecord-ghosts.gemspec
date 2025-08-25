# frozen_string_literal: true

require_relative "lib/activerecord/ghosts/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-ghosts"
  spec.version = ActiveRecord::Ghosts::VERSION
  spec.authors = ["Ilya Kovalenko"]
  spec.email = ["a@fromilya.com"]

  spec.summary = "Virtual rows for ActiveRecord models - fill in the gaps in your sequences with ghost records"
  spec.description = "ActiveRecord::Ghosts allows you to define a sequence column and query with ranges to get real + ghost records. Ghost records behave like AR objects but aren't persisted, perfect for filling gaps in sequences like levels, numbers, etc."
  spec.homepage = "https://github.com/ilyacoding/activerecord-ghosts"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ilyacoding/activerecord-ghosts"
  spec.metadata["changelog_uri"] = "https://github.com/ilyacoding/activerecord-ghosts/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activerecord", ">= 7.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
