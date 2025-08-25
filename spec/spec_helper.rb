# frozen_string_literal: true

require "activerecord/ghosts"
require "rails"
require "active_record/railtie"
require "rspec/rails"

# Load support files
Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use Rails 5+ behavior
  config.infer_spec_type_from_file_location!
end
