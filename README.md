# ActiveRecord::Ghosts 👻

"Virtual rows" for ActiveRecord models.
Fill in the gaps in your sequencFor best performance, ensure the ghosted column (e.g. `:level`) has an **index**.
If it doesn't, you'll see a warning:

```
[activerecord-ghosts] ⚠️ Column :level on progress_levels has no leading index. Ghost queries may be slow.
``` work with **ghost records** that behave like AR objects but aren’t persisted.

---

## ✨ Features

- Define a sequence column (like `number`).
- Query with a range and get **real + ghost records**.
- Chain with `where` / scopes.
- Works with `Enumerator` for infinite series.
- Ghost records respond to `.ghost?`.

---

## 🚀 Installation

**Requirements:**
- Ruby 3.4.0+
- Rails 7.0+

Add to your Gemfile:

```ruby
gem "activerecord-ghosts"
````

and run:

```bash
bundle install
```

---

## 🛠 Usage

### 1. Enable ghosts on your model

```ruby
class ProgressLevel < ApplicationRecord
  belongs_to :user
  has_ghosts :level
end
```

---

### 2. Generate a ghost series

```ruby
ProgressLevel.ghosts(1..5).map { |level| [level.level, level.ghost?] }
# => [[1, false], [2, false], [3, true], [4, true], [5, true]]
```

Here:

* Levels `1` and `2` exist in DB → `ghost? == false`
* Levels `3..5` don't exist → ghost objects (`ghost? == true`)

---

### 3. Combine with conditions

For a specific user:

```ruby
user = User.find(1)
user.progress_levels.ghosts(1..5).map { |level| [level.level, level.user_id, level.ghost?] }
# => [
#   [1, 1, false],
#   [2, 1, false],
#   [3, 1, true],
#   [4, 1, true],
#   [5, 1, true]
# ]

# Alternative syntax:
ProgressLevel.where(user_id: user.id).ghosts(1..5).map { |level| [level.level, level.user_id, level.ghost?] }
```

Ghosts automatically inherit `where` conditions as defaults.

---

### 4. Infinite series

Without arguments, `.ghosts` returns an **Enumerator**:

```ruby
ProgressLevel.ghosts.take(3).map { |level| [level.level, level.ghost?] }
# => [[1, false], [2, false], [3, true]]
```

You can `each`, `each_slice`, etc.
Records are lazily loaded batch by batch.

---

## ⚠️ Performance note

For best performance, ensure the ghosted column (e.g. `:number`) has an **index**.
If it doesn’t, you’ll see a warning:

```
[activerecord-ghosts] ⚠️ Column :number on invoices has no leading index. Ghost queries may be slow.
```

Composite indexes are fine if your ghost column is the **leading** column.

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

See [TRUSTED_PUBLISHING.md](TRUSTED_PUBLISHING.md) for setup details.

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
