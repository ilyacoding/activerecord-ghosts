# frozen_string_literal: true

require "active_record"
require "database_cleaner/active_record"

# Configure database
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Create test tables
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.timestamps
  end

  create_table :progress_levels do |t|
    t.references :user, null: false, foreign_key: true
    t.integer :level
    t.integer :points, default: 0
    t.boolean :completed, default: false
    t.timestamps
  end

  create_table :invoices do |t|
    t.integer :number
    t.boolean :paid, default: false
    t.decimal :amount
    t.timestamps
  end

  # Add indexes for performance testing
  add_index :progress_levels, :level
  add_index :progress_levels, %i[user_id level]
  add_index :invoices, :number
end

# Test models
class User < ActiveRecord::Base
  has_many :progress_levels, dependent: :destroy
end

class ProgressLevel < ActiveRecord::Base
  belongs_to :user
  has_ghosts :level
end

class Invoice < ActiveRecord::Base
  has_ghosts :number
end

# Configure database cleaner
DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
