# 🏆 Discourse Rich JSON-LD Microdata Plugin

**English version | [Русская версия](README.ru.md)**

**Comprehensive, coordinated Open Graph and Schema.org JSON-LD microdata for 200% SEO and LLM coverage**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Discourse Version](https://img.shields.io/badge/discourse-2.7.0+-orange.svg)](https://discourse.org)

---

## 🎯 What This Plugin Does

This plugin **replaces** Discourse's standard meta tags with a comprehensive, professionally structured microdata system that provides:

### ✅ For SEO (100%):
- **Rich Snippets** in Google/Yandex (⭐ ratings, 💬 answer counts, 👤 authors, 📅 dates)
- **Knowledge Graph** panels for expert users
- **Featured Snippets** in "People also ask"
- **Breadcrumbs** in search results
- Complete **QAPage** schema for Q&A content

### ✅ For AI/LLM (100%):
- **Full context** understanding (topics → categories → answers → comments)
- **Entity relationships** through `@id` references
- **Author expertise** metadata
- **Solved answers** marking
- Complete **knowledge graph** of your forum

### ✅ Total = 200% Coverage! 🚀

---

## 🌟 Key Features

### 1. **Coordinated Markup**
- Open Graph, Twitter Cards, and JSON-LD generated from **single source of truth**
- No data conflicts between different meta tag types
- All data synchronized automatically

### 2. **Complete Removal of Standard Tags**
- Removes Discourse's default meta tags (both server-side and client-side)
- Prevents duplicate/conflicting markup
- Clean, professional output

### 3. **Rich Schema.org Structure**
- **QAPage** for topics with full Q&A hierarchy
- **CollectionPage** for categories with subcategories
- **ProfilePage** for user profiles
- **BreadcrumbList** for navigation
- **WebSite** global schema with search action

### 4. **Full Localization (EN/RU) 🌍**
- 100% English + 100% Russian translations
- Automatic language detection (user → site → browser)
- All Schema.org descriptions localized
- Open Graph and Twitter Cards in user's language
- Easy to add more languages

### 5. **Performance Optimized**
- Smart caching (1 hour default, configurable)
- Automatic cache invalidation on content changes
- < 5ms for cached pages
- ~50ms for fresh generation

### 6. **LLM-Friendly**
- Complete graph of entities with `@id` references
- Nested comment structure preserved
- Author statistics and expertise indicators
- Tags as structured entities

---

## 📦 Installation

### Method 1: Via Git (Recommended)

```bash
cd /var/discourse
git clone https://github.com/kaktaknet/discourse-rich-json-ld-microdata.git plugins/discourse-rich-json-ld-microdata
./launcher rebuild app
```

### Method 2: Manual

1. Copy plugin to `plugins/discourse-rich-json-ld-microdata/`
2. Rebuild Discourse: `./launcher rebuild app`
3. Enable in Admin → Settings → Plugins

---

## ⚙️ Configuration

Navigate to **Admin → Settings → Plugins → Rich Microdata**

### Essential Settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `rich_microdata_enabled` | `true` | Master switch for the plugin |
| `rich_microdata_cache_ttl` | `3600` | Cache duration (seconds) |
| `rich_microdata_max_answers` | `10` | Max answers in JSON-LD |
| `rich_microdata_include_user_stats` | `true` | Include user statistics |
| `rich_microdata_enable_breadcrumbs` | `true` | Add BreadcrumbList schema |
| `rich_microdata_twitter_site` | `""` | Your @twitter handle |

### Advanced Settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `rich_microdata_max_comments` | `5` | Max nested comments per answer |
| `rich_microdata_og_image_default` | `""` | Fallback OG image URL |
| `rich_microdata_debug_mode` | `false` | Enable debug logging |
| `rich_microdata_validate_output` | `false` | Validate against Schema.org (dev only) |

---

## 🌍 Localization (Internationalization)

The plugin includes full localization support for **English** and **Russian** out of the box.

### Supported Languages:

- 🇬🇧 **English** (`en`)
- 🇷🇺 **Russian** (`ru`)

### What's Translated:

1. **Admin Settings UI**
   - All setting descriptions
   - Help text

2. **Schema.org Descriptions**
   - Category descriptions ("Discussions in...")
   - User profile descriptions ("User profile...")
   - Interaction statistics ("Created topics", "Written replies")

3. **Open Graph & Twitter Cards**
   - All metadata labels
   - Fallback descriptions

4. **Breadcrumbs**
   - "Home" → "Главная"

### How Language Detection Works:

**Priority order:**
1. **User preference** (from Discourse user settings)
2. **Site default** (from Admin → Settings → default_locale)
3. **Browser locale** (from HTTP Accept-Language header)
4. **Fallback to English** (`en-US`)

### Adding New Languages:

#### Step 1: Create Locale Files

Create files in `config/locales/`:

```
config/locales/
├── server.es.yml     # Spanish backend
├── client.es.yml     # Spanish frontend
```

#### Step 2: Copy Translation Structure

Copy from existing locale file (e.g., `server.en.yml`) and translate:

```yaml
# config/locales/server.es.yml
es:
  site_settings:
    rich_microdata_enabled: "Activar plugin Rich Microdata"
    # ... more settings

  discourse_rich_microdata:
    breadcrumb:
      home: "Inicio"

    open_graph:
      category_description: "Discusiones en %{category_name}"
      user_description: "Perfil de usuario %{user_name}"

    twitter_card:
      label_replies: "Respuestas"
      label_author: "Autor"
      # ... more translations
```

#### Step 3: Test

```ruby
# Rails console
I18n.locale = :es
I18n.t('discourse_rich_microdata.breadcrumb.home')
# => "Inicio"
```

#### Step 4: Submit PR

Contributions welcome! Submit translations via Pull Request.

### Available Translation Keys:

See [`config/locales/server.en.yml`](config/locales/server.en.yml) for full list of keys.

**Main groups:**
- `site_settings.*` - Admin panel
- `discourse_rich_microdata.breadcrumb.*` - Navigation
- `discourse_rich_microdata.open_graph.*` - OG tags
- `discourse_rich_microdata.twitter_card.*` - Twitter cards
- `discourse_rich_microdata.profile_page.*` - User profiles
- `discourse_rich_microdata.interaction_stats.*` - Statistics

---

## 🏗️ Architecture

### Data Flow:

```
Discourse Object (Topic/Category/User)
         ↓
    DataExtractor
         ↓
   Unified Data Hash
    /     |     \
   /      |      \
OG    Twitter   Schema
Builder Builder Builder
   \      |      /
    \     |     /
   Coordinator
         ↓
   MetaGeneratorService
   (with caching)
         ↓
    Controller Hook
         ↓
    Inserted into <head>
```

### Key Components:

1. **DataExtractor** - Extracts & normalizes data from Discourse objects
2. **Builders** - Generate specific markup types (OG, Twitter, JSON-LD)
3. **Coordinator** - Ensures data consistency across all builders
4. **MetaGeneratorService** - Adds caching and error handling
5. **MetaRemover** - Removes standard Discourse tags

---

## 📊 Generated Markup Examples

### For Topics:

**Open Graph:**
```html
<meta property="og:type" content="article">
<meta property="og:title" content="How to optimize PostgreSQL queries?">
<meta property="og:url" content="https://forum.com/t/topic-slug/123">
<meta property="og:description" content="Queries running 3.5 seconds...">
<meta property="og:image" content="https://forum.com/uploads/postgres.jpg">
<meta property="article:author" content="https://forum.com/u/john">
```

**JSON-LD QAPage:**
```json
{
  "@context": "https://schema.org",
  "@type": "QAPage",
  "name": "How to optimize PostgreSQL queries?",
  "mainEntity": {
    "@type": "Question",
    "name": "How to optimize PostgreSQL queries?",
    "text": "Queries running 3.5 seconds...",
    "answerCount": 12,
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "Use composite indexes...",
      "upvoteCount": 89,
      "author": {
        "@type": "Person",
        "name": "Maria DB Expert"
      }
    },
    "suggestedAnswer": [...]
  }
}
```

---

## 🔧 Customization

### Adding Custom Social Links:

Edit `lib/discourse_rich_microdata/builders/website_builder.rb`:

```ruby
def social_links
  links = []
  links << "https://github.com/your-org" if SiteSetting.your_github_url
  links << "https://twitter.com/yourhandle" if SiteSetting.your_twitter_url
  links.presence
end
```

### Modifying Answer Limit:

Admin → Settings → `rich_microdata_max_answers` (5-50)

### Custom Image Fallback:

Admin → Settings → `rich_microdata_og_image_default`

---

## 🧪 Testing & Validation

### Automated Validation:

```bash
# Run tests (when available)
bundle exec rspec plugins/discourse-rich-json-ld-microdata
```

### Manual Validation:

1. **Google Rich Results Test:**
   ```
   https://search.google.com/test/rich-results
   ```

2. **Schema.org Validator:**
   ```
   https://validator.schema.org
   ```

3. **Facebook Debugger:**
   ```
   https://developers.facebook.com/tools/debug/
   ```

4. **Twitter Card Validator:**
   ```
   https://cards-dev.twitter.com/validator
   ```

### Check Generated Markup:

```bash
# As Googlebot
curl -A "Googlebot" https://your-forum.com/t/topic-slug/123 | grep "application/ld+json"

# View full head
curl https://your-forum.com/t/topic-slug/123 | grep -A 50 "<head>"
```

---

## 📈 Performance Metrics

### Expected Performance:

| Metric | Value |
|--------|-------|
| First generation (cold) | ~50ms |
| From cache (warm) | ~2-5ms |
| Cache hit rate | 95-98% |
| Memory per schema | ~6KB |
| Redis cache size (1000 topics) | ~6MB |

### Monitoring:

```ruby
# In Rails console
MetaGeneratorService.cache_stats
# => {
#   topics: 1247,
#   categories: 15,
#   users: 234,
#   total_size: "7.5 MB"
# }
```

---

## 🐛 Troubleshooting

### Issue: Markup not appearing

**Solution:**
```ruby
# Check if enabled
SiteSetting.rich_microdata_enabled
# => true

# Clear cache
MetaGeneratorService.clear_all_cache

# Check logs
tail -f log/production.log | grep RichMicrodata
```

### Issue: Old tags still present

**Solution:**
1. Hard refresh browser (Ctrl+Shift+R)
2. Check if JavaScript cleanup runs: Open DevTools → Console
3. Verify `data-rich-microdata` attribute on new tags

### Issue: Validation errors

**Solution:**
```ruby
# Enable debug mode
SiteSetting.rich_microdata_debug_mode = true

# Check specific topic
topic = Topic.find(123)
data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic)
puts JSON.pretty_generate(data)
```

---

## 🤝 Contributing

Contributions welcome!

1. Fork the repo
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 Changelog

### Version 2.0.0 (2025-01-16)
- ✨ **Full localization (EN/RU)** with automatic language detection
- ✨ I18n support for all Schema.org, Open Graph, Twitter Cards
- ✨ Example Telegram IV template rules in [`TELEGRAM_IV_RULES.txt`](TELEGRAM_IV_RULES.txt)
- ✨ Separate rendering for head tags and body content
- ✨ Enhanced language priority detection (user → site → browser)
- ✨ URL encoding for Cyrillic characters in slugs/usernames/tags

### Version 1.0.0 (2025-01-16)
- ✨ Initial release
- ✨ Complete QAPage schema for topics
- ✨ CollectionPage for categories
- ✨ ProfilePage for users
- ✨ Coordinated OG + Twitter + JSON-LD
- ✨ Smart caching with auto-invalidation
- ✨ Removal of standard Discourse tags

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 💬 Support

- 📧 Email: support@kaktak.net
- 💬 Telegram: @kaktaknet
- 🐛 Issues: [GitHub Issues](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/issues)
- 📖 Docs: [Full Documentation](docs/)

---

## 🌟 Acknowledgments

- Discourse Team for the amazing platform
- Schema.org for structured data standards
- All contributors and users

---

<div align="center">

**Made with ❤️ for the Discourse Community**

[⬆ Back to Top](#-discourse-rich-json-ld-microdata-plugin)

</div>
