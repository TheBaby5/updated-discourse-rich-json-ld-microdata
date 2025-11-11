# Discourse Rich JSON-LD Microdata

| | | |
| - | - | - |
| :sparkles: | **Summary** | Replaces Discourse's standard meta tags with comprehensive, coordinated Open Graph, Twitter Cards, and Schema.org JSON-LD markup for superior SEO, social media sharing, and AI/LLM discoverability |
| :hammer_and_wrench: | **Repository Link** | https://github.com/kaktaknet/discourse-rich-json-ld-microdata |
| :open_book: | **Install Guide** | [How to install plugins in Discourse](https://meta.discourse.org/t/install-plugins-in-discourse/19157) |

<br>

### What You Get

Transform how your forum appears in search results, social media, and AI-powered assistants. This plugin generates professional-grade structured data that Google, Yandex, social platforms, and Large Language Models understand perfectly.

**For detailed documentation**, see [README.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/README.md)

**For technical details and development**, see [CONTRIBUTING.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/CONTRIBUTING.md)

**For usage examples and troubleshooting**, see [USAGE.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/USAGE.md)

### Rich Search Results Examples

**Before**: Plain text snippet in Google
**After**: Rich snippet with ratings, answer counts, author, and publish date

![Google Rich Snippet Example](https://developers.google.com/static/search/docs/images/qanda-example.png)

**Before**: Generic link preview in social media
**After**: Eye-catching card with image, description, and branding

Learn more about [Rich Results from Google Search Central](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data)

### Key Features

**1. Complete Schema.org Coverage**
- **QAPage schema** for topics with full Q&A hierarchy
- **Answer ratings** and **solved status** support
- **CollectionPage** for categories with subcategories
- **ProfilePage** for user profiles with expertise indicators
- **BreadcrumbList** for navigation paths
- **WebSite** global schema with search action

**2. Coordinated Social Media Tags**
- Open Graph (Facebook, LinkedIn, Discord)
- Twitter Cards (summary_large_image)
- All generated from **single source of truth** - no conflicts
- Automatic cleanup of Discourse's default tags

**3. AI & LLM Optimized**
- Complete entity relationships using Schema.org `@id` references
- Full context understanding (topics → categories → answers → comments)
- Author expertise metadata
- ChatGPT, Claude, and other AI assistants get perfect context

**4. Full Internationalization 🌍**
- 100% English and Russian translations included
- Automatic language detection (user → site → browser → fallback)
- All Schema.org descriptions localized
- Easy to add more languages

**5. Smart Performance**
- Redis caching with 1-hour TTL (configurable)
- Automatic cache invalidation on content changes
- < 5ms for cached pages
- ~50ms for fresh generation

**6. Zero Maintenance**
- Automatic injection for both browser and crawler views
- Works for topics, categories, and user profiles
- Graceful error handling - never breaks your site
- Comprehensive logging for debugging

### Benefits for Your Forum

**🎯 Better Search Rankings**
- Rich snippets in Google increase click-through rates by 30-50%
- Knowledge Graph panels for expert users
- Featured in "People also ask" sections
- Breadcrumbs in search results improve navigation

**📱 Professional Social Sharing**
- Eye-catching cards when shared on Facebook, Twitter, LinkedIn
- Proper branding with logos and descriptions
- Increased engagement and click-through rates
- Works across 40+ social platforms

**🤖 AI Assistant Ready**
- Your content appears accurately in ChatGPT and Claude responses
- Proper attribution with links back to your forum
- Complete context prevents AI hallucinations
- Future-proof for Generative Engine Optimization (GEO)

**🌍 International Audience**
- Automatic language detection
- Localized descriptions for better relevance
- URL encoding handles Cyrillic and special characters
- Easy expansion to more languages

### Installation

**Step 1: Install via Git**

```bash
cd /var/discourse
git clone https://github.com/kaktaknet/discourse-rich-json-ld-microdata.git plugins/discourse-rich-json-ld-microdata
./launcher rebuild app
```

**Step 2: Enable in Admin**

Navigate to **Admin → Settings → Plugins → Rich Microdata**

Set `rich_microdata_enabled` to `true` (enabled by default)

**Step 3: Configure (Optional)**

All settings work great out-of-the-box, but you can customize:
- Cache duration (default: 1 hour)
- Max answers to include (default: 10)
- Twitter @handle for your site
- Default Open Graph image URL
- Enable/disable specific schemas

**Step 4: Verify**

Test your markup:
- [Google Rich Results Test](https://search.google.com/test/rich-results)
- [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
- [Schema.org Validator](https://validator.schema.org/)

### Configuration

| Setting | Default | Description |
|-|-|-|
| `rich_microdata_enabled` | `true` | Master switch for the plugin |
| `rich_microdata_cache_ttl` | `3600` | Cache duration in seconds |
| `rich_microdata_max_answers` | `10` | Max answers in QAPage schema |
| `rich_microdata_include_user_stats` | `true` | Include user statistics |
| `rich_microdata_enable_breadcrumbs` | `true` | Add BreadcrumbList schema |
| `rich_microdata_enable_website_schema` | `true` | Include WebSite schema |
| `rich_microdata_twitter_site` | `""` | Your Twitter @username |
| `rich_microdata_og_image_default` | `""` | Fallback OG image URL |
| `rich_microdata_debug_mode` | `false` | Enable debug logging |

### Technical Details

**Architecture:**
- Three-layer pattern: DataExtractor → Builders → Coordinator
- Single source of truth prevents data conflicts
- Separate rendering for `<head>` tags and `<body>` content
- Works with both `application.html.erb` and `crawler.html.erb` layouts

**Standards Compliance:**
- Schema.org JSON-LD specification
- Open Graph Protocol
- Twitter Cards markup
- RFC 3986 (URL encoding for international characters)

**Security:**
- Guardian permission checks
- Private content automatically excluded
- SQL-level security filtering
- Safe fallbacks for missing data

**Compatibility:**
- Discourse 2.7.0+
- Ruby 2.7+
- Tested on Discourse 3.6.0.beta3

### Real-World Examples

**Topic Page Markup:**
```json
{
  "@context": "https://schema.org",
  "@type": "QAPage",
  "name": "How to optimize database queries?",
  "mainEntity": {
    "@type": "Question",
    "name": "How to optimize database queries?",
    "text": "I'm experiencing slow queries...",
    "answerCount": 5,
    "upvoteCount": 12,
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "You should add indexes on...",
      "upvoteCount": 8,
      "author": {
        "@type": "Person",
        "name": "John Doe",
        "url": "https://forum.example.com/u/john"
      }
    }
  }
}
```

**Category Page Markup:**
```json
{
  "@context": "https://schema.org",
  "@type": "CollectionPage",
  "name": "Database Optimization",
  "description": "Tips and tricks for faster queries",
  "numberOfItems": 245,
  "hasPart": [...]
}
```

See [USAGE.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/USAGE.md) for complete examples.

### Use Cases

**Technical Forums:**
Developers find your solutions through Google's featured snippets and AI coding assistants, with proper code context preserved.

**Support Communities:**
Search engines display your answers with ratings and solved status, driving qualified traffic to your best content.

**Discussion Forums:**
Social media sharing looks professional with custom cards, increasing engagement and reducing bounce rates.

**International Communities:**
Automatic language detection ensures users see content in their preferred language, improving accessibility.

### Maintenance

**Zero-maintenance operation:**
- Automatic cache refresh on content updates
- Self-healing on errors (never breaks your site)
- Comprehensive logging for monitoring
- Optional debug mode for troubleshooting

**Cache management (optional):**
```ruby
# Rails console
MetaGeneratorService.clear_all_cache
MetaGeneratorService.cache_stats
```

### Troubleshooting

**Meta tags not appearing:**
1. Verify plugin enabled in Admin → Plugins
2. Check logs: `./launcher logs app | grep RichMicrodata`
3. Clear cache: `MetaGeneratorService.clear_all_cache`

**Rich snippets not showing in Google:**
- Google takes 2-4 weeks to re-crawl and update
- Test with [Rich Results Test](https://search.google.com/test/rich-results)
- Check for validation errors in Search Console

See [USAGE.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/USAGE.md) for detailed troubleshooting.

### Performance Metrics

- **Cache hit rate**: 95%+ for typical forums
- **Response time**: < 5ms cached, ~50ms fresh
- **Memory overhead**: Minimal (uses Redis)
- **Database load**: Negligible (cached 1 hour)

### Roadmap

Current version: **2.0.0**

✅ Complete Open Graph and Twitter Cards
✅ Full Schema.org JSON-LD support
✅ EN/RU localization
✅ URL encoding for international characters

Planned:
- Additional language packs (ES, DE, FR)
- Video schema support
- Event schema for announcements
- Product schema for marketplace categories

### Support

- **Issues**: [GitHub Issues](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/issues)
- **Documentation**: [README.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/README.md)
- **Contributing**: [CONTRIBUTING.md](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/CONTRIBUTING.md)
- **Email**: support@kaktak.net
- **Telegram**: @kaktaknet

### License

MIT License - Free and open-source software

### Credits

- **Standards**: [Schema.org](https://schema.org/), [Open Graph Protocol](https://ogp.me/), [Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)
- **Platform**: [Discourse](https://www.discourse.org/)
- **Community**: All contributors and users

---

### Optional: Telegram Instant View

The repository includes example template rules in [`TELEGRAM_IV_RULES.txt`](https://github.com/kaktaknet/discourse-rich-json-ld-microdata/blob/main/TELEGRAM_IV_RULES.txt) for creating beautiful Telegram Instant View templates. Use these rules at [instantview.telegram.org](https://instantview.telegram.org/) to provide fast-loading, distraction-free reading experience for users who share your forum content in Telegram.

---

**Transform your forum's visibility today.** Install in under 5 minutes, see results in Google within 2-4 weeks. 🚀
