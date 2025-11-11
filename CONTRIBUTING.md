# Contributing to Discourse Rich JSON-LD Microdata Plugin

First off, thank you for considering contributing! 🎉

This document provides guidelines for contributing to this project. Following these guidelines helps maintain code quality and makes the review process smoother.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Adding Translations](#adding-translations)
- [Submitting Pull Requests](#submitting-pull-requests)
- [Release Process](#release-process)

---

## 📜 Code of Conduct

This project follows the [Discourse Community Guidelines](https://meta.discourse.org/guidelines). Be respectful, constructive, and help create a welcoming environment.

---

## 🤝 How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
1. Check the [Issues](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/issues) to see if it's already reported
2. Update to the latest version to see if the bug still exists
3. Collect as much information as possible

**When submitting a bug report, include:**
- Plugin version
- Discourse version
- Ruby version
- Steps to reproduce
- Expected vs actual behavior
- Error messages (from `log/production.log`)
- Generated markup (if relevant)

**Example bug report:**

```markdown
### Bug: Open Graph image not displaying

**Environment:**
- Plugin version: 2.0.0
- Discourse version: 3.1.0
- Ruby version: 3.2.1

**Steps to reproduce:**
1. Create topic with image
2. Check OG meta tags
3. Image URL is missing

**Expected:**
`<meta property="og:image" content="https://forum.com/uploads/image.jpg">`

**Actual:**
`<meta property="og:image" content="">`

**Error log:**
```
[RichMicrodata] ERROR: DataExtractor failed to extract image
```
```

### Suggesting Features

**Before suggesting a feature:**
1. Check if it aligns with the plugin's goals (SEO + LLM coverage)
2. Search existing issues for similar requests
3. Consider if it could be a separate plugin

**When suggesting a feature, include:**
- Clear use case
- Example implementation (if possible)
- Impact on performance
- Schema.org compliance (if adding new schema types)

### Adding Translations

We welcome translations to new languages!

**See [Adding New Languages](#adding-new-languages) section below.**

---

## 🛠️ Development Setup

### Prerequisites

- Discourse development environment ([setup guide](https://meta.discourse.org/t/beginners-guide-to-install-discourse-for-development-using-docker/102009))
- Ruby 3.1+ (same as Discourse)
- Git

### Local Development

1. **Clone the repository:**

   ```bash
   cd discourse
   git clone https://github.com/kaktaknet/discourse-rich-json-ld-microdata.git plugins/discourse-rich-json-ld-microdata
   ```

2. **Install dependencies:**

   ```bash
   bundle install
   ```

3. **Start Discourse:**

   ```bash
   bin/rails server
   ```

4. **Enable the plugin:**

   Navigate to `http://localhost:3000/admin/plugins` and enable the plugin.

5. **Test your changes:**

   ```bash
   # Run RSpec tests (when available)
   bundle exec rspec plugins/discourse-rich-json-ld-microdata/spec

   # Check for Ruby syntax errors
   rubocop plugins/discourse-rich-json-ld-microdata
   ```

### Development Workflow

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes

3. Test locally:
   ```ruby
   # Rails console
   topic = Topic.find(123)
   result = MetaGeneratorService.generate_for_topic(topic, nil, nil)
   puts result[:head]
   puts result[:body]
   ```

4. Check markup validity:
   - [Google Rich Results Test](https://search.google.com/test/rich-results)
   - [Schema.org Validator](https://validator.schema.org/)

5. Commit with clear message:
   ```bash
   git commit -m "Add: Feature X for better Schema.org coverage"
   ```

---

## 📁 Project Structure

```
discourse-rich-json-ld-microdata/
├── plugin.rb                           # Main plugin file
├── config/
│   ├── settings.yml                    # Admin settings
│   └── locales/                        # Translations (server + client)
├── lib/discourse_rich_microdata/
│   ├── language_helper.rb              # Language detection
│   ├── data_extractor.rb               # Data normalization (single source of truth)
│   ├── meta_remover.rb                 # Remove standard Discourse tags
│   ├── coordinator.rb                  # Coordinate all builders
│   └── builders/
│       ├── base_builder.rb             # Base class with helpers
│       ├── open_graph_builder.rb       # Open Graph meta tags
│       ├── twitter_card_builder.rb     # Twitter Cards
│       ├── schema_builder.rb           # JSON-LD combiner
│       ├── qa_page_builder.rb          # QAPage for topics
│       ├── collection_page_builder.rb  # CollectionPage for categories
│       ├── profile_page_builder.rb     # ProfilePage for users
│       ├── breadcrumb_builder.rb       # BreadcrumbList
│       └── website_builder.rb          # WebSite global schema
├── app/services/
│   └── meta_generator_service.rb       # Caching service
├── assets/
│   ├── javascripts/                    # Frontend components
│   └── stylesheets/                    # CSS
└── spec/                               # Tests (TODO)
```

### Key Components

**DataExtractor (`lib/discourse_rich_microdata/data_extractor.rb`)**
- Extracts data from Discourse objects
- Normalizes into unified hash structure
- **Single source of truth** for all builders
- Handles image extraction, text sanitization, URL generation

**Builders (`lib/discourse_rich_microdata/builders/*.rb`)**
- Each builder generates specific markup type
- All builders extend `BaseBuilder`
- Use data from `DataExtractor` (never fetch from DB directly)
- Return formatted HTML or JSON

**Coordinator (`lib/discourse_rich_microdata/coordinator.rb`)**
- Orchestrates all builders
- Ensures data consistency
- Returns `{ head:, body: }` hash

**MetaGeneratorService (`app/services/meta_generator_service.rb`)**
- Adds caching layer (Redis)
- Handles errors gracefully
- Invalidates cache on content changes

---

## 💻 Coding Standards

### Ruby Style Guide

Follow [Discourse's Ruby style guide](https://github.com/discourse/discourse/blob/main/.rubocop.yml).

**Key rules:**
- 2 spaces indentation (no tabs)
- No trailing whitespace
- Max line length: 120 characters
- Use `frozen_string_literal: true`
- Descriptive variable names (no single-letter except loops)

### Comments

- **Minimize comments** - code should be self-explanatory
- Only comment **complex logic** that isn't obvious
- Use English for all comments
- No commented-out code (use Git instead)

**Good:**
```ruby
# Calculate final score using weighted average of likes and views
score = (likes * 0.7) + (views * 0.3) / total_interactions
```

**Bad:**
```ruby
# This is the score
score = (likes * 0.7) + (views * 0.3) / total_interactions # calculate score
```

### Naming Conventions

- **Classes:** `PascalCase` (e.g., `OpenGraphBuilder`)
- **Methods:** `snake_case` (e.g., `extract_topic_data`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `SCHEMA_CONTEXT`)
- **Private methods:** Prefix with `private` keyword

### Builder Pattern

When creating new builders:

```ruby
module DiscourseRichMicrodata
  module Builders
    class YourBuilder < BaseBuilder
      def build
        # Return Hash or String
        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "YourType",
          # ... your schema
        }.tap { |schema| compact_hash(schema) }
      end

      private

      def your_helper_method
        # Helper logic
      end
    end
  end
end
```

**Builder rules:**
- Extend `BaseBuilder`
- Implement `build` method
- Use `compact_hash` to remove nil values
- Use `t()` for translations
- Never query database directly (use `data` from constructor)

---

## 🧪 Testing Guidelines

### Manual Testing

**1. Test generated markup:**

```ruby
# Rails console
topic = Topic.find(123)
topic_view = TopicView.new(topic)
controller = TopicsController.new

result = MetaGeneratorService.generate_for_topic(topic, topic_view, controller)

# Check head tags
puts result[:head]

# Check body tags (JSON-LD)
puts result[:body]
```

**2. Validate with external tools:**
- Google Rich Results Test
- Schema.org Validator
- Facebook Debugger
- Twitter Card Validator

**3. Test caching:**

```ruby
# First call (cold)
Benchmark.ms { MetaGeneratorService.generate_for_topic(topic) }
# => ~50ms

# Second call (warm)
Benchmark.ms { MetaGeneratorService.generate_for_topic(topic) }
# => ~2ms
```

**4. Test language detection:**

```ruby
# Mock user locale
user.update(locale: 'ru')
controller = mock_controller(current_user: user)

result = MetaGeneratorService.generate_for_topic(topic, nil, controller)
# Check if Russian translations are used
```

### Unit Tests (TODO)

We welcome contributions for RSpec tests!

**Example test structure:**

```ruby
# spec/lib/builders/open_graph_builder_spec.rb
require 'rails_helper'

describe DiscourseRichMicrodata::Builders::OpenGraphBuilder do
  let(:topic) { Fabricate(:topic) }
  let(:data) { DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic) }
  let(:builder) { described_class.new(data, {}) }

  describe '#build' do
    it 'generates valid Open Graph tags' do
      result = builder.build
      expect(result).to include('og:title')
      expect(result).to include('og:url')
    end
  end
end
```

---

## 🌍 Adding Translations

### Step 1: Create Locale Files

Create two files in `config/locales/`:

```
config/locales/
├── server.{locale}.yml     # Backend translations
└── client.{locale}.yml     # Frontend translations
```

### Step 2: Copy and Translate

**Server translations** (`config/locales/server.fr.yml`):

```yaml
fr:
  site_settings:
    rich_microdata_enabled: "Activer le plugin Rich Microdata"
    rich_microdata_cache_ttl: "Durée du cache en secondes"
    # ... more settings

  discourse_rich_microdata:
    breadcrumb:
      home: "Accueil"

    open_graph:
      category_description: "Discussions dans %{category_name}"
      user_description: "Profil de %{user_name}"

    twitter_card:
      label_replies: "Réponses"
      label_author: "Auteur"
      label_topics: "Sujets"
      label_posts: "Messages"
      label_karma: "Karma"

    profile_page:
      title: "Profil de %{user_name}"

    interaction_stats:
      created_topics: "Sujets créés"
      written_replies: "Réponses écrites"
      received_likes: "J'aime reçus"
      read_posts: "Messages lus"
      number_of_topics: "Nombre de sujets"
      number_of_replies: "Nombre de réponses"
```

### Step 3: Test Translations

```ruby
# Rails console
I18n.locale = :fr
I18n.t('discourse_rich_microdata.breadcrumb.home')
# => "Accueil"

I18n.t('discourse_rich_microdata.open_graph.category_description', category_name: 'Tech')
# => "Discussions dans Tech"
```

### Step 4: Submit Pull Request

Include in PR description:
- Language added
- Native speaker verification (if possible)
- Screenshot of translated UI (optional)

---

## 🚀 Submitting Pull Requests

### Before Submitting

**Checklist:**
- [ ] Code follows style guide
- [ ] All existing tests pass
- [ ] New code is tested manually
- [ ] Markup validated with Schema.org validator
- [ ] No console errors in browser
- [ ] Performance is not degraded
- [ ] Documentation updated (if needed)
- [ ] Translations added (if adding user-facing strings)
- [ ] CHANGELOG.md updated

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Translation
- [ ] Documentation
- [ ] Performance improvement

## Testing
How did you test this?

## Validation
- [ ] Google Rich Results: ✅ / ❌
- [ ] Schema.org Validator: ✅ / ❌
- [ ] Facebook Debugger: ✅ / ❌

## Screenshots (if applicable)

## Related Issues
Closes #123
```

### PR Review Process

1. **Automated checks** (if configured)
   - Syntax check
   - Style check
   - Basic tests

2. **Manual review**
   - Code quality
   - Schema.org compliance
   - Performance impact
   - Security implications

3. **Testing in staging**
   - Deploy to test environment
   - Verify generated markup
   - Check cache behavior

4. **Approval & merge**
   - Requires 1 approval from maintainer
   - Squash merge preferred

---

## 📦 Release Process

*(For maintainers only)*

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **Major (X.0.0):** Breaking changes
- **Minor (x.Y.0):** New features (backward compatible)
- **Patch (x.y.Z):** Bug fixes

### Release Steps

1. **Update version** in `plugin.rb`:
   ```ruby
   # version: 2.1.0
   ```

2. **Update CHANGELOG.md:**
   ```markdown
   ### Version 2.1.0 (2025-01-20)
   - ✨ Added X feature
   - 🐛 Fixed Y bug
   - 📚 Improved Z documentation
   ```

3. **Create Git tag:**
   ```bash
   git tag -a v2.1.0 -m "Release 2.1.0"
   git push origin v2.1.0
   ```

4. **Create GitHub Release:**
   - Go to Releases → New Release
   - Select tag `v2.1.0`
   - Copy changelog
   - Publish

5. **Announce:**
   - Post on Discourse Meta
   - Update plugin directory listing

---

## 💡 Development Tips

### Debugging

**Enable debug mode:**
```ruby
# Rails console
SiteSetting.rich_microdata_debug_mode = true
```

**Check logs:**
```bash
tail -f log/development.log | grep RichMicrodata
```

**Inspect data extraction:**
```ruby
topic = Topic.find(123)
data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic)
puts JSON.pretty_generate(data)
```

**Test specific builder:**
```ruby
data = { title: "Test", posts: [...] }
builder = DiscourseRichMicrodata::Builders::QAPageBuilder.new(data, {})
puts JSON.pretty_generate(builder.build)
```

### Performance Profiling

```ruby
require 'benchmark'

Benchmark.bm do |x|
  x.report("cold:") { MetaGeneratorService.generate_for_topic(topic) }
  x.report("warm:") { MetaGeneratorService.generate_for_topic(topic) }
end
```

### Common Pitfalls

1. **Don't query database in builders**
   ❌ `User.find(author_id)`
   ✅ Use data from `data` hash

2. **Always compact hashes**
   ❌ Return hash with nil values
   ✅ Use `compact_hash(hash)`

3. **Use translations**
   ❌ Hardcode "Home" string
   ✅ Use `t('breadcrumb.home')`

4. **Validate output**
   Always test with Schema.org validator

---

## 📞 Getting Help

- **Questions:** Open a [Discussion](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/discussions)
- **Bugs:** Open an [Issue](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/issues)
- **Chat:** Telegram @kaktaknet
- **Email:** support@kaktak.net

---

## 🎉 Thank You!

Every contribution helps make this plugin better for the entire Discourse community!

**Notable Contributors:**
- [Add your name here with first PR]

---

## 📚 Additional Resources

- [Discourse Plugin Development](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins/30515)
- [Schema.org Documentation](https://schema.org/docs/schemas.html)
- [Open Graph Protocol](https://ogp.me/)
- [Google Search Central](https://developers.google.com/search/docs/appearance/structured-data)
