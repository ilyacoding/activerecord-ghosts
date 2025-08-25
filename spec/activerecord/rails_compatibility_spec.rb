# frozen_string_literal: true

RSpec.describe "Rails version compatibility" do
  describe "where_values_hash compatibility" do
    let(:user) { User.create!(name: "Test User") }

    before do
      ProgressLevel.create!(user: user, level: 1, completed: true)
    end

    it "handles where_values_hash across Rails versions" do
      relation = ProgressLevel.where(user_id: user.id, completed: true)

      # This should work in both Rails 7 and 8
      values_hash = relation.where_values_hash
      expect(values_hash).to include("user_id" => user.id, "completed" => true)

      # Test that ghosts inherit these conditions
      results = relation.ghosts(1..3)
      ghost_records = results.select(&:ghost?)

      ghost_records.each do |ghost|
        expect(ghost.user_id).to eq(user.id)
        expect(ghost.completed).to be true
      end
    end

    it "works with symbolized keys" do
      relation = ProgressLevel.where(user: user, completed: false)
      results = relation.ghosts(2..2)
      ghost = results.first

      expect(ghost.ghost?).to be true
      expect(ghost.user_id).to eq(user.id)
      expect(ghost.completed).to be false
    end
  end

  describe "ActiveRecord relation methods" do
    let(:user) { User.create!(name: "Test User") }

    it "works with includes" do
      ProgressLevel.create!(user: user, level: 1)

      # This should work without N+1 queries
      results = ProgressLevel.includes(:user).where(user: user).ghosts(1..3)

      expect(results.length).to eq(3)
      expect(results.first.user).to eq(user)
    end

    it "works with joins" do
      ProgressLevel.create!(user: user, level: 1)

      results = ProgressLevel.joins(:user).where(users: { name: "Test User" }).ghosts(1..2)

      expect(results.length).to eq(2)
      expect(results.first.level).to eq(1)
      expect(results.first.ghost?).to be false
    end

    it "works with order" do
      ProgressLevel.create!(user: user, level: 3)
      ProgressLevel.create!(user: user, level: 1)

      results = ProgressLevel.where(user: user).order(:level).ghosts(1..4)

      expect(results.map(&:level)).to eq([1, 2, 3, 4])
    end
  end

  describe "Rails 8 specific features" do
    # Test features that might be specific to Rails 8
    it "handles new ActiveRecord features gracefully" do
      # This test will pass in older Rails versions and test new features in Rails 8
      relation = ProgressLevel.where(user_id: 1)

      # Should not break with any Rails version
      expect do
        relation.ghosts(1..2)
      end.not_to raise_error
    end
  end

  # Test Ruby 3.4+ features compatibility
  describe "Ruby 3.4+ compatibility" do
    it "works with pattern matching" do
      user = User.create!(name: "Test User")
      ProgressLevel.create!(user: user, level: 1)

      results = user.progress_levels.ghosts(1..2)
      first_result = results.first

      # Pattern matching syntax (Ruby 3.0+) with hash-like access
      record_info = { level: first_result.level, ghost: first_result.ghost? }
      case record_info
      in { level: 1, ghost: false }
        expect(true).to be true
      else
        raise "Pattern matching failed - got level: #{first_result.level}, ghost: #{first_result.ghost?}"
      end
    end

    it "uses modern Ruby features appropriately" do
      # Test that the gem works with Ruby 3.4 features
      user = User.create!(name: "Test User")
      results = user.progress_levels.ghosts(1..3)

      # Use shorthand hash syntax and numbered parameters
      expect(results.all? { it.user_id == user.id }).to be true
    end
  end
end
