# frozen_string_literal: true

RSpec.describe ActiveRecord::Ghosts do
  it "has a version number" do
    expect(ActiveRecord::Ghosts::VERSION).not_to be_nil
  end

  describe "has_ghosts class method" do
    it "adds ghosts method to the model" do
      expect(ProgressLevel).to respond_to(:ghosts)
      expect(Invoice).to respond_to(:ghosts)
    end

    it "adds ghosts method to instances" do
      user = User.create!(name: "Test User")
      expect(user.progress_levels).to respond_to(:ghosts)
    end
  end

  describe "ghost records" do
    let(:user) { User.create!(name: "Test User") }

    before do
      # Create some real records
      ProgressLevel.create!(user: user, level: 1, points: 100, completed: true)
      ProgressLevel.create!(user: user, level: 3, points: 300, completed: false)

      Invoice.create!(number: 1, paid: true, amount: 100.0)
      Invoice.create!(number: 2, paid: false, amount: 200.0)
    end

    describe "with range parameter" do
      it "returns mix of real and ghost records" do
        results = ProgressLevel.where(user: user).ghosts(1..5)

        expect(results).to have_attributes(length: 5)

        # Check real records
        expect(results[0]).to have_attributes(level: 1, ghost?: false, points: 100, completed: true)
        expect(results[2]).to have_attributes(level: 3, ghost?: false, points: 300, completed: false)

        # Check ghost records
        expect(results[1]).to have_attributes(level: 2, ghost?: true, points: 0, completed: false)
        expect(results[3]).to have_attributes(level: 4, ghost?: true, points: 0, completed: false)
        expect(results[4]).to have_attributes(level: 5, ghost?: true, points: 0, completed: false)
      end

      it "inherits where conditions in ghost records" do
        results = ProgressLevel.where(user: user, completed: true).ghosts(1..3)

        # Real record
        expect(results[0]).to have_attributes(level: 1, ghost?: false, completed: true)

        # Ghost records should inherit completed: true
        expect(results[1]).to have_attributes(level: 2, ghost?: true, completed: true)
        expect(results[2]).to have_attributes(level: 3, ghost?: true, completed: true)
      end

      it "works with association scopes" do
        results = user.progress_levels.ghosts(1..4)

        expect(results).to have_attributes(length: 4)
        results.each do |record|
          expect(record.user_id).to eq(user.id)
        end
      end

      it "works with Invoice model" do
        results = Invoice.ghosts(1..4)

        expect(results).to have_attributes(length: 4)
        expect(results[0]).to have_attributes(number: 1, ghost?: false, paid: true)
        expect(results[1]).to have_attributes(number: 2, ghost?: false, paid: false)
        expect(results[2]).to have_attributes(number: 3, ghost?: true, paid: false)
        expect(results[3]).to have_attributes(number: 4, ghost?: true, paid: false)
      end
    end

    describe "without range parameter (enumerator)" do
      it "returns an enumerator" do
        result = ProgressLevel.where(user: user).ghosts
        expect(result).to be_a(Enumerator)
      end

      it "yields real and ghost records lazily" do
        enum = ProgressLevel.where(user: user).ghosts
        first_three = enum.take(3)

        expect(first_three).to have_attributes(length: 3)
        expect(first_three[0]).to have_attributes(level: 1, ghost?: false)
        expect(first_three[1]).to have_attributes(level: 2, ghost?: true)
        expect(first_three[2]).to have_attributes(level: 3, ghost?: false)
      end

      it "continues beyond existing records" do
        enum = ProgressLevel.where(user: user).ghosts
        many_records = enum.take(10)

        expect(many_records).to have_attributes(length: 10)
        # Should have real records at positions 1 and 3
        expect(many_records[0].ghost?).to be false  # level 1
        expect(many_records[2].ghost?).to be false  # level 3
        # All others should be ghosts
        [1, 3, 4, 5, 6, 7, 8, 9].each do |index|
          expect(many_records[index].ghost?).to be true
        end
      end
    end

    describe "ghost? method" do
      it "returns false for real records" do
        real_record = ProgressLevel.find_by(level: 1)
        expect(real_record.ghost?).to be false
      end

      it "returns true for ghost records" do
        ghost_records = ProgressLevel.where(user: user).ghosts(2..2)
        expect(ghost_records.first.ghost?).to be true
      end
    end

    describe "inspect method for ghosts" do
      it "adds ghost prefix to inspect output" do
        ghost_records = ProgressLevel.where(user: user).ghosts(2..2)
        ghost = ghost_records.first

        expect(ghost.inspect).to include("#<ghost ProgressLevel")
      end

      it "doesn't modify inspect for real records" do
        real_record = ProgressLevel.find_by(level: 1)
        expect(real_record.inspect).to include("#<ProgressLevel")
        expect(real_record.inspect).not_to include("ghost")
      end
    end

    describe "edge cases" do
      it "handles empty ranges" do
        results = ProgressLevel.where(user: user).ghosts(5..4) # invalid range
        expect(results).to be_empty
      end

      it "handles ranges with no existing records" do
        results = ProgressLevel.where(user: user).ghosts(10..12)

        expect(results).to have_attributes(length: 3)
        results.each do |record|
          expect(record.ghost?).to be true
        end
      end

      it "handles single element ranges" do
        results = ProgressLevel.where(user: user).ghosts(2..2)

        expect(results).to have_attributes(length: 1)
        expect(results.first).to have_attributes(level: 2, ghost?: true)
      end
    end

    describe "performance warnings" do
      before do
        allow($stderr).to receive(:write) # Suppress stderr during tests
      end

      it "warns when no index exists on ghost column" do
        # Create a model without index
        expect(ProgressLevel.connection).to receive(:indexes).and_return([])
        expect do
          Class.new(ActiveRecord::Base) do
            self.table_name = "progress_levels"
            has_ghosts :level
          end
        end.to output(/Column :level.*has no leading index/).to_stderr
      end
    end
  end

  describe "Rails version compatibility" do
    it "works with current Rails version" do
      expect { ProgressLevel.where(user_id: 1).ghosts(1..3) }.not_to raise_error
    end

    it "handles where_values_hash correctly" do
      relation = ProgressLevel.where(user_id: 1, completed: true)
      results = relation.ghosts(1..2)

      results.each do |record|
        if record.ghost?
          expect(record.user_id).to eq(1)
          expect(record.completed).to be true
        end
      end
    end
  end
end
