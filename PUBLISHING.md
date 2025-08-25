# Publishing to RubyGems

This**Security features implemented:**

1. **Owner-only Releases**: Only `@ilyacoding` can create tags and trigger releases
2. **Environment Protection**: Uses `production` environment that requires manual approval
3. **Environment Variable**: API key passed as `GEM_HOST_API_KEY` environment variable (RubyGems standard)
4. **Secret Isolation**: API key is not exposed in shell commands or logs
5. **Tag-only Deployment**: Only deploys on version tags, not on every push
6. **Test Before Deploy**: Runs full test suite before publishing
7. **Version Validation**: Pre-release checks ensure tag matches code version
8. **Code Review**: All changes require code owner approvalnt describes how to publish the activerecord-ghosts gem to RubyGems.

## Prerequisites

1. You need a RubyGems account: https://rubygems.org/sign_up
2. Get your API key from: https://rubygems.org/profile/edit
3. Add the API key to GitHub Secrets as `RUBYGEMS_API_KEY`

## Security Measures

### Repository Access Control

1. **CODEOWNERS**: All changes require approval from `@ilyacoding`
2. **Branch Protection**: Main branch is protected with required reviews
3. **Tag Protection**: Only `@ilyacoding` can create version tags
4. **Workflow Restrictions**: Only `@ilyacoding` can trigger releases

### GitHub Repository Setup

**Required manual setup** (one-time only):

1. **Branch Protection Rules**: See `.github/BRANCH_PROTECTION.md`
2. **Environment Setup**:
   - Create `production` environment
   - Add `@ilyacoding` as required reviewer
   - Set `RUBYGEMS_API_KEY` secret (environment-specific)
3. **Tag Protection**: Restrict `v*` tags to repository admins only

### Security features implemented:

1. **Environment Protection**: Uses `production` environment that can require manual approval
2. **Environment Variable**: API key passed as `GEM_HOST_API_KEY` environment variable (RubyGems standard)
3. **Secret Isolation**: API key is not exposed in shell commands or logs
4. **Tag-only Deployment**: Only deploys on version tags, not on every push
5. **Test Before Deploy**: Runs full test suite before publishing

### Setting up Environment Protection (Recommended)

1. Go to: Settings → Environments → New environment
2. Name it `production`
3. Add protection rules:
   - Required reviewers (yourself)
   - Wait timer (optional)
   - Deployment branches: only protected branches

## Publishing Process

### 1. Manual Publishing

To publish manually:

```bash
# Build the gem
gem build activerecord-ghosts.gemspec

# Push to RubyGems (replace YOUR_API_KEY)
gem push activerecord-ghosts-0.0.1.gem
```

### 2. Automated Publishing via GitHub Actions

The repository includes GitHub Actions for automated publishing:

1. **Create a new tag:**
   ```bash
   git tag v0.0.1
   git push origin v0.0.1
   ```

2. **The publish action will automatically:**
   - Run tests
   - Build the gem
   - Publish to RubyGems

### 3. Version Updates

To release a new version:

1. Update the version in `lib/activerecord/ghosts/version.rb`
2. Update `CHANGELOG.md` with new changes
3. Commit the changes
4. Create a new tag: `git tag vX.Y.Z`
5. Push the tag: `git push origin vX.Y.Z`

## GitHub Secrets Setup

Go to: Settings → Secrets and variables → Actions → New repository secret

**Never commit API keys to code!** Always use GitHub Secrets for sensitive data.

## Workflow Structure

- **ci.yml**: Runs tests on every push/PR
- **publish.yml**: Publishes gem only on version tags with security measures
