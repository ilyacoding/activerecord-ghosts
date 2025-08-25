# ActiveRecord::Ghosts 👻

"Virtual rows" for ActiveRecord models.
Fill in the gaps in your sequences and work with **ghost records** that behave like AR objects but aren't persisted.

---

## ✨ Features

- Define a sequence column (like `level`, `number`).
- Query with a range and get **real + ghost records**.
- Chain with `where` / scopes.
- Works with `Enumerator` for infinite series.
- Ghost records respond to `.ghost?`.

---

## 🚀 Installation

**Requirements:**
- Ruby 3.4.0+
- Rails 7.2+

Add to your Gemfile:

```ruby
gem "activerecord-ghosts"
```

and run:

```bash
bundle install
```

---

## 🏗 Setup

### Database Schema

Your model needs an **integer column** for the sequence field. This column should be indexed for performance.

```ruby
# Example migration
class CreateProgressLevels < ActiveRecord::Migration[7.2]
  def change
    create_table :progress_levels do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :level, null: false  # ← Ghost sequence column
      t.integer :points, default: 0
      t.timestamps
    end

    # Index for performance (IMPORTANT!)
    add_index :progress_levels, [:user_id, :level], unique: true
    # OR simple index if no associations:
    # add_index :progress_levels, :level
  end
end
```

### Model Configuration

```ruby
class ProgressLevel < ApplicationRecord
  belongs_to :user

  # Enable ghosts on the integer sequence column
  has_ghosts :level, start: 1  # Optional: custom start value (default: 1)

  validates :level, presence: true, uniqueness: { scope: :user_id }
end

# Alternative start values:
class Invoice < ApplicationRecord
  has_ghosts :number, start: 1000  # Start from 1000 instead of 1
end

# Usage with custom start:
Invoice.ghosts.take(3)  # Will generate ghosts starting from 1000, 1001, 1002...
```

**Requirements:**
- ✅ Ghost column must be **integer type**
- ✅ Ghost column should have an **index** (composite or simple)
- ✅ Index should have ghost column as **leading column** for best performance

---

## 🛠 Usage

### 1. Basic ghost series

```ruby
# Assuming you have levels 1, 2, 5 in database
ProgressLevel.ghosts(1..6).map { |level| [level.level, level.ghost?] }
# => [[1, false], [2, false], [3, true], [4, true], [5, false], [6, true]]
```

---

### 2. With associations and scoping

For a specific user:

```ruby
user = User.find(1)

# Get levels 1-5 for this user (mix of real + ghost records)
user.progress_levels.ghosts(1..5).each do |level|
  puts "Level #{level.level}: #{level.ghost? ? 'Missing' : 'Completed'} (#{level.points} points)"
end
# Output:
# Level 1: Completed (100 points)
# Level 2: Completed (150 points)
# Level 3: Missing (0 points)      ← Ghost inherits default values
# Level 4: Missing (0 points)      ← Ghost inherits default values
# Level 5: Missing (0 points)      ← Ghost inherits default values

# Alternative syntax:
ProgressLevel.where(user_id: user.id).ghosts(1..5)
```

**Key insight:** Ghost records automatically inherit `where` conditions and model defaults!

---

### 3. Infinite series

Without arguments, `.ghosts` returns an **Enumerator** that starts from the `start` value:

```ruby
# With default start: 1
ProgressLevel.ghosts.take(3).map { |level| [level.level, level.ghost?] }
# => [[1, false], [2, false], [3, true]]

# With custom start: 1000
class Invoice < ApplicationRecord
  has_ghosts :number, start: 1000
end

Invoice.ghosts.take(3).map { |inv| [inv.number, inv.ghost?] }
# => [[1000, true], [1001, true], [1002, true]]  # Starts from 1000!
```

You can `each`, `each_slice`, etc. Records are lazily loaded batch by batch.

---

## 📋 Supported Column Types & Limitations

### ✅ Supported Ghost Columns
- **Integer columns only** - `t.integer :level`, `t.bigint :number`, etc.
- Must contain **sequential numeric values** (1, 2, 3... or 10, 20, 30...)
- Works with any integer range (`1..100`, `0..10`, `-5..5`)

### ❌ Not Supported
- String columns (`t.string :name`)
- Date/DateTime columns (`t.date :created_on`)
- UUID columns (`t.uuid :external_id`)
- Non-sequential data

### 🎯 Perfect Use Cases
```ruby
# ✅ Game levels (1, 2, 3, 4, 5...)
class PlayerLevel
  has_ghosts :level  # integer column
end

# ✅ Invoice numbers (1, 2, 3... or 1000, 1001, 1002...)
class Invoice
  has_ghosts :number  # integer column
end

# ✅ Chapter numbers in a book
class Chapter
  has_ghosts :chapter_number  # integer column
end

# ❌ Don't use for non-sequential data
class User
  has_ghosts :email  # ❌ String - won't work
  has_ghosts :created_at  # ❌ DateTime - not sequential
end
```

---

## ⚠️ Performance note

For best performance, ensure the ghosted column (e.g. `:level`) has an **index**.
If it doesn't, you'll see a warning:

```
[activerecord-ghosts] ⚠️ Column :level on progress_levels has no leading index. Ghost queries may be slow.
```

Composite indexes are fine if your ghost column is the **leading** column.

---

## ❓ FAQ

### Q: Can I use string/UUID columns as ghost fields?
**A:** No, only integer columns are supported. Ghost records fill numeric gaps in sequences.

### Q: Do ghost records get saved to the database?
**A:** No! Ghost records exist only in memory. They behave like ActiveRecord objects but `.persisted?` returns `false`.

### Q: Can I modify ghost records?
**A:** Yes! You can call `.save!` on a ghost record to persist it to the database. After saving, `.ghost?` will return `false`.

### Q: How do I handle gaps in my sequence?
**A:** That's exactly what this gem does! It fills gaps with virtual records.

```ruby
# You have records [1, 2, 5, 8] in database
Model.ghosts(1..10).map(&:id)
# Returns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# Where 3, 4, 6, 7, 9, 10 are ghosts
```

### Q: What about performance with large ranges?
**A:** Use the enumerator version for infinite sequences:

```ruby
# ✅ Memory efficient - loads in batches
Model.ghosts.take(1000)

# ❌ Avoid large ranges - loads all at once
Model.ghosts(1..1000000)
```

---

## 📦 Development

Clone and setup:

```bash
git clone https://github.com/ilyacoding/activerecord-ghosts
cd activerecord-ghosts
bundle install
```

## 🚀 Development & Publishing

### Local Development

```bash
bundle install
bundle exec rspec
```

### Automated Publishing

This gem uses **RubyGems.org Trusted Publishing** for secure, automated releases.

**Release Process:**
1. Update version in `lib/activerecord/ghosts/version.rb`
2. Commit and create tag: `git tag v0.1.1 && git push --tags`
3. GitHub Actions automatically publishes to RubyGems.org

### Running Tests

```bash
bundle exec rspec
```

---

## 📜 License

MIT © Ilya Kovalenko

---

## 🤝 Contributing

Pull requests welcome!
By participating you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
