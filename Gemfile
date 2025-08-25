# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in activerecord-ghosts.gemspec
gemspec

# Additional development tools (not needed by other gem developers)
gem "irb"
gem "rake", "~> 13.0"

# Development dependencies
gem "database_cleaner-active_record"
gem "factory_bot"
gem "rspec", "~> 3.0"
gem "rspec-rails"

# Code quality
gem "rubocop", "~> 1.21"
gem "rubocop-rspec"

# Rails versions for testing (CI matrix)
rails_version = ENV.fetch("RAILS_VERSION", "7.2")
gem "rails", "~> #{rails_version}.0"

# Rails 7.2+ requires sqlite3 >= 2.1
gem "sqlite3", ">= 2.1"
