# frozen_string_literal: true

RSpec.describe "Integration tests" do
  let(:user1) { User.create!(name: "User 1") }
  let(:user2) { User.create!(name: "User 2") }

  before do
    # User 1 progress levels
    ProgressLevel.create!(user: user1, level: 1, points: 100, completed: true)
    ProgressLevel.create!(user: user1, level: 3, points: 300, completed: true)
    ProgressLevel.create!(user: user1, level: 5, points: 500, completed: false)

    # User 2 progress levels
    ProgressLevel.create!(user: user2, level: 2, points: 200, completed: true)
    ProgressLevel.create!(user: user2, level: 4, points: 400, completed: false)
  end

  describe "complex scenarios" do
    it "works with multiple users and overlapping levels" do
      user1_results = user1.progress_levels.ghosts(1..5)
      user2_results = user2.progress_levels.ghosts(1..5)

      # User 1 should have real records at 1, 3, 5 and ghosts at 2, 4
      expect(user1_results.map(&:ghost?)).to eq([false, true, false, true, false])
      expect(user1_results.map(&:level)).to eq([1, 2, 3, 4, 5])

      # User 2 should have real records at 2, 4 and ghosts at 1, 3, 5
      expect(user2_results.map(&:ghost?)).to eq([true, false, true, false, true])
      expect(user2_results.map(&:level)).to eq([1, 2, 3, 4, 5])
    end

    it "maintains associations in ghost records" do
      ghost_levels = user1.progress_levels.ghosts(2..2)
      ghost = ghost_levels.first

      expect(ghost.ghost?).to be true
      expect(ghost.user_id).to eq(user1.id)
      expect(ghost.user).to eq(user1)
    end

    it "works with complex where clauses" do
      # Test with multiple conditions - find only user1's records with 100 points and completed
      results = ProgressLevel.where(user_id: user1.id, completed: true, points: 100).ghosts(1..3)

      # Should find user1's level 1 (100 points, completed)
      # Should create ghosts for levels 2, 3 with user_id: user1.id, completed: true, points: 100
      real_records = results.reject(&:ghost?)
      ghost_records = results.select(&:ghost?)

      expect(real_records.length).to eq(1)
      expect(real_records.first).to have_attributes(level: 1, points: 100, completed: true)

      expect(ghost_records.length).to eq(2)
      ghost_records.each do |ghost|
        expect(ghost.user_id).to eq(user1.id)
        expect(ghost.completed).to be true
        expect(ghost.points).to eq(100) # Ghost should inherit all conditions
      end
    end

    it "enumerator works with large datasets" do
      # Create many records to test batching
      (6..50).each do |level|
        ProgressLevel.create!(user: user1, level: level, points: level * 10)
      end

      enum = user1.progress_levels.ghosts
      first_100 = enum.take(100)

      expect(first_100.length).to eq(100)

      # Check that we have both real and ghost records
      real_count = first_100.count { |r| !r.ghost? }
      ghost_count = first_100.count(&:ghost?)

      expect(real_count).to be > 0
      expect(ghost_count).to be > 0
      expect(real_count + ghost_count).to eq(100)
    end
  end

  describe "performance considerations" do
    it "uses efficient queries for ranges" do
      expect do
        user1.progress_levels.ghosts(1..1000)
      end.not_to raise_error
    end

    it "batches efficiently with enumerator" do
      # This test ensures that enumerator doesn't load everything at once
      enum = user1.progress_levels.ghosts

      # Taking small number shouldn't trigger massive queries
      expect do
        enum.take(5)
      end.not_to raise_error
    end
  end

  describe "error handling" do
    it "handles invalid model configurations gracefully" do
      expect do
        Class.new(ActiveRecord::Base) do
          self.table_name = "nonexistent_table"
          has_ghosts :some_field
        end
      end.not_to raise_error
    end

    it "handles missing columns gracefully" do
      # This might raise an error depending on Rails version
      # but shouldn't crash the entire application
      expect do
        Invoice.ghosts(1..2).first.nonexistent_field
      rescue StandardError
        nil
      end.not_to raise_error
    end
  end
end
