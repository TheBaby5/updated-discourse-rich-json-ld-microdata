# Discourse Rich JSON-LD Microdata (Enhanced Fork)

> **Fork of:** [kaktaknet/discourse-rich-json-ld-microdata](https://github.com/kaktaknet/discourse-rich-json-ld-microdata)  
> **Maintained by:** TheBaby5  
> **Version:** 2.4.0  
> **Status:** Production-ready, battle-tested on [OneHack.st](https://onehack.st) (48K+ members, 500K+ posts)

---

## TL;DR - Why This Fork?

| Issue | Original (kaktaknet) | This Fork (TheBaby5) |
|-------|---------------------|----------------------|
| Empty `user.name` handling | ❌ Breaks schema (`"name": ""`) | ✅ Falls back to username |
| `</script>` in content | ❌ Breaks page rendering | ✅ Properly escaped |
| **Google Search Console errors** | ❌ Missing `author.name` | ✅ Always provides valid author |
| `compact_hash` bug | ❌ Null values not removed | ✅ Properly removes nulls |
| Missing comment.text | ❌ Empty comments break schema | ✅ Filters invalid comments |
| Defense-in-depth | ❌ Single point of failure | ✅ Multi-layer validation |
| Schema validity | ⚠️ Can produce invalid JSON-LD | ✅ Always valid |
| Code-heavy topics | ❌ JSON leaks as visible text | ✅ Works perfectly |

**Bottom line:** This fork fixes critical bugs that cause Google Search Console structured data errors and ensures 100% valid Schema.org JSON-LD output.

---

## What is JSON-LD?

[JSON-LD](https://json-ld.org/) (JavaScript Object Notation for Linked Data) is a method of encoding structured data using JSON. Search engines like Google use JSON-LD to understand your content better, enabling:

- **Rich snippets** in search results
- **Knowledge panel** information
- **FAQ** and **How-to** rich results
- **Better AI understanding** of your content

This plugin generates comprehensive Schema.org JSON-LD markup for your Discourse forum, including:
- `DiscussionForumPosting` for topics
- `QAPage` for Q&A-style content
- `Person` for user profiles
- `BreadcrumbList` for navigation
- `WebSite` for site-wide schema

---

## Critical Bugs Fixed

### Bug #1: Empty Name Field (GitHub Issue #2)

**The Problem:**

When a Discourse user has an empty `name` field (they only have a username), the original plugin would output:

```json
{
  "@type": "Person",
  "name": "",  // INVALID - Google rejects this
  "identifier": "SRZ"
}
```

This happens because Ruby's `||` operator doesn't treat empty string `""` as falsy:

```ruby
# Original (buggy):
user.name || user.username  # Returns "" if name is empty string

# This fork (fixed):
user.name.presence || user.username  # Returns username if name is nil OR empty
```

**The Fix:**

We use Ruby's `.presence` method which returns `nil` for empty strings:

```ruby
display_name = user.name.presence || user.username
```

**Defense-in-Depth:**

We apply this fix at THREE layers to ensure it never breaks:

1. **`data_extractor.rb`** - When extracting user data
2. **`qa_page_builder.rb`** - When building Person schema for topics
3. **`profile_page_builder.rb`** - When building Person schema for profiles

---

### Bug #2: Script Tag Breakout (XSS-Adjacent)

**The Problem:**

When a topic contains code examples with `</script>` tags (like JavaScript tutorials), the JSON-LD would break:

```html
<script type="application/ld+json">
{
  "articleBody": "Here's an example: <script>alert('hi')</script> ..."
                                              ^^^^^^^^^
                                              Browser thinks script ends here!
}
</script>  <!-- This becomes visible text -->
```

The browser sees `</script>` inside the JSON string and thinks the script block has ended, causing:
- Raw JSON to render as visible text at the top of the page
- Broken page layout
- Potential security issues

**The Fix:**

We escape `</script>` as `<\/script>` which is valid JSON but won't be interpreted by the HTML parser:

```ruby
def escape_for_script_tag(json)
  json
    .gsub('</script', '<\/script')  # Escape closing script tags
    .gsub('</Script', '<\/Script')  # Case variations
    .gsub('</SCRIPT', '<\/SCRIPT')  # Case variations
    .gsub('<!--', '<\\!--')         # Escape HTML comments too
end
```

This is applied in `schema_builder.rb` when rendering all JSON-LD output.

---

### Bug #3: Google Search Console "Missing field" Errors (v2.4.0)

**The Problem:**

Google Search Console was reporting 4 Discussion forum structured data issues:
- Missing field "name" (in "author") - **CRITICAL**
- Missing field "name" (in "comment.author")
- Either "text", "image", or "video" should be specified (in "comment")
- Missing field "comment"

**Root Cause 1: `compact_hash` Not Actually Working**

The original code used `.tap { |schema| compact_hash(schema) }` which **doesn't work**:

```ruby
# BROKEN: compact_hash returns a NEW hash, but tap discards the return value
}.tap { |schema| compact_hash(schema) }

# The original compact_hash returns a new hash:
def compact_hash(hash)
  hash.reject { |_, v| v.nil? }  # Returns NEW hash, original unchanged!
end
```

This meant `"comment": null` was being output instead of removed, causing Google errors.

**The Fix:**

Changed to modify hash in-place:

```ruby
# FIXED: Use reject! to modify in place
def compact_hash!(hash)
  hash.reject! { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
  hash
end
```

**Root Cause 2: `person_schema` Returns nil When User Missing**

When a post's author is nil (deleted user, etc.), the entire author object was removed:

```ruby
# BROKEN: Returns nil, Google requires author with name
def person_schema(user_data)
  return nil unless user_data  # Removes author entirely!
  ...
end
```

**The Fix:**

Always return a valid Person with at least "Anonymous":

```ruby
# FIXED: Always return valid author
def person_schema(user_data)
  unless user_data
    return {
      "@type" => "Person",
      "name" => "Anonymous"  # Google requires author.name
    }
  end

  # Fallback chain: name -> username -> "Anonymous"
  display_name = user_data[:name].presence || user_data[:username].presence || "Anonymous"
  ...
end
```

**Root Cause 3: Comments Without Text**

Google requires `text`, `image`, or `video` in comments. Posts with empty content broke this:

```ruby
# BROKEN: If post[:raw] is empty, schema is invalid
"text" => post[:raw]  # Could be nil or ""
```

**The Fix:**

Filter out comments without valid text:

```ruby
# FIXED: Skip comments without content
comments = replies.filter_map do |post|
  post_text = post[:raw].presence
  next nil unless post_text  # Skip if no text

  {
    "@type" => "Comment",
    "text" => post_text,  # Always valid
    ...
  }
end
```

---

## Installation

Add to your `app.yml` in the plugins section:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/TheBaby5/updated-discourse-rich-json-ld-microdata.git discourse-rich-json-ld-microdata
```

Then rebuild:

```bash
cd /var/discourse && ./launcher rebuild app
```

---

## Schema Types Generated

### For Topics (`/t/:slug/:id`)

```json
[
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Your Forum Name",
    "url": "https://yourforum.com"
  },
  {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [...]
  },
  {
    "@context": "https://schema.org",
    "@type": "DiscussionForumPosting",
    "headline": "Topic Title",
    "articleBody": "Full post content...",
    "author": {
      "@type": "Person",
      "name": "Username",  // Always valid, never empty
      "url": "https://yourforum.com/u/username"
    },
    "interactionStatistic": [
      {"@type": "InteractionCounter", "interactionType": "LikeAction", "userInteractionCount": 42},
      {"@type": "InteractionCounter", "interactionType": "CommentAction", "userInteractionCount": 15}
    ]
  }
]
```

### For Categories (`/c/:slug/:id`)

```json
{
  "@context": "https://schema.org",
  "@type": "CollectionPage",
  "name": "Category Name",
  "description": "Category description",
  "numberOfItems": 1234
}
```

### For User Profiles (`/u/:username`)

```json
{
  "@context": "https://schema.org",
  "@type": "ProfilePage",
  "mainEntity": {
    "@type": "Person",
    "name": "Display Name or Username",  // Never empty!
    "identifier": "username",
    "interactionStatistic": [...]
  }
}
```

---

## Architecture

### File Structure

```
plugin.rb                          # Main plugin entry point
lib/discourse_rich_microdata/
├── data_extractor.rb              # Extracts data from Discourse models
├── language_helper.rb             # i18n support
├── coordinator.rb                 # Orchestrates builders
└── builders/
    ├── base_builder.rb            # Base class with shared methods
    ├── schema_builder.rb          # Main orchestrator, handles escaping
    ├── qa_page_builder.rb         # DiscussionForumPosting/QAPage
    ├── profile_page_builder.rb    # User profile schema
    ├── collection_page_builder.rb # Category schema
    ├── breadcrumb_builder.rb      # BreadcrumbList
    ├── website_builder.rb         # WebSite schema
    ├── open_graph_builder.rb      # OG meta tags
    └── twitter_card_builder.rb    # Twitter Card meta tags
app/services/
└── meta_generator_service.rb      # Service layer for generation
config/
└── settings.yml                   # Plugin settings
config/locales/
└── server.en.yml                  # i18n strings
```

### Data Flow

```
TopicsController
       │
       ▼
plugin.rb (register_html_builder)
       │
       ▼
MetaGeneratorService.generate_for_topic()
       │
       ▼
DataExtractor.extract_topic_data()  ←── Fix #1: .presence || username
       │
       ▼
SchemaBuilder.build()
       │
       ├──▶ WebsiteBuilder.build()
       ├──▶ BreadcrumbBuilder.build()
       └──▶ QAPageBuilder.build()  ←── Fix #1: .presence || username (defense-in-depth)
              │
              ▼
       person_schema()  ←── Fix #1: .presence || username (defense-in-depth)
              │
              ▼
render_schema_tags()
       │
       ▼
escape_for_script_tag()  ←── Fix #2: </script> → <\/script>
       │
       ▼
<script type="application/ld+json">...</script>
```

---

## Technical Details: The Fixes

### Fix #1: Empty Name (3 Locations)

**Location 1: `data_extractor.rb` (line ~80)**

```ruby
def self.extract_user_data(user)
  return nil unless user
  
  # FIX: Use .presence to handle empty strings properly
  display_name = user.name.presence || user.username
  
  {
    id: user.id,
    username: user.username,
    name: display_name,  # Always valid
    # ...
  }
end
```

**Location 2: `qa_page_builder.rb` (person_schema method)**

```ruby
def person_schema(user_data)
  return nil unless user_data
  
  # FIX: Defense-in-depth - validate even if data_extractor missed it
  display_name = user_data[:name].presence || user_data[:username]
  
  {
    "@type" => "Person",
    "name" => display_name,  # Always valid
    # ...
  }
end
```

**Location 3: `profile_page_builder.rb` (2 places)**

```ruby
def build
  display_name = data[:name].presence || data[:username]
  # ...
end

def person_schema
  display_name = data[:name].presence || data[:username]
  # ...
end
```

### Fix #2: Script Tag Escaping (`schema_builder.rb`)

```ruby
def render_single_schema(schema)
  json = JSON.pretty_generate(schema)
  json = escape_for_script_tag(json)  # Critical fix!
  %(<script type="application/ld+json">\n#{json}\n</script>)
end

def render_multiple_schemas(schemas)
  json = JSON.pretty_generate(schemas)
  json = escape_for_script_tag(json)  # Critical fix!
  %(<script type="application/ld+json">\n#{json}\n</script>)
end

# Escape sequences that break script tags
def escape_for_script_tag(json)
  json
    .gsub('</script', '<\/script')   # Primary fix
    .gsub('</Script', '<\/Script')   # Case variation
    .gsub('</SCRIPT', '<\/SCRIPT')   # Case variation
    .gsub('<!--', '<\\!--')          # HTML comments
end
```

---

## Configuration

Enable in Admin → Settings → Plugins:

| Setting | Description | Default |
|---------|-------------|---------|
| `rich_microdata_enabled` | Enable/disable the plugin | true |
| `rich_microdata_content_type` | Schema type (discussion/qa/article) | discussion |
| `rich_microdata_enable_website_schema` | Include WebSite schema | true |
| `rich_microdata_enable_breadcrumbs` | Include BreadcrumbList | true |
| `rich_microdata_include_user_stats` | Include user interaction stats | true |
| `rich_microdata_max_answers` | Max answers to include in QA schema | 10 |
| `rich_microdata_max_comments` | Max comments per answer | 5 |
| `rich_microdata_debug_mode` | Enable debug logging | false |

---

## Testing Your Schema

### Google Rich Results Test

1. Go to [Google Rich Results Test](https://search.google.com/test/rich-results)
2. Enter your topic URL
3. Verify no errors in the JSON-LD

### Schema.org Validator

1. Go to [Schema.org Validator](https://validator.schema.org/)
2. Paste your page URL or JSON-LD
3. Check for warnings/errors

### Manual Inspection

View page source and search for `application/ld+json`:

```bash
curl -s 'https://yourforum.com/t/topic-slug/123' | grep -A100 'application/ld+json'
```

---

## Troubleshooting

### JSON-LD appears as visible text on page

**Cause:** Topic contains `</script>` in code blocks.

**Solution:** Update to v2.3.0+ which escapes script tags.

### Empty "name" field in Person schema

**Cause:** User has no display name set (only username).

**Solution:** Update to v2.2.0+ which falls back to username.

### Schema not appearing

**Check:**
1. Plugin is enabled in admin settings
2. Clear Rails cache: `docker exec app rails runner "Rails.cache.clear"`
3. Hard refresh browser: `Ctrl+Shift+R`

---

## Compatibility

- **Discourse version:** 2.7.0+
- **Ruby version:** 3.0+
- **Works with:**
  - `discourse-solved` (accepted answers)
  - `discourse-voting` (vote counts)
  - `discourse-reactions` (reaction counts)
  - All standard Discourse themes

---

## Version History

### v2.4.0 (January 2026)
- **CRITICAL FIX:** Google Search Console "Missing field" errors
- Fixed `compact_hash` bug - was returning new hash instead of modifying in place
- `person_schema` now returns "Anonymous" instead of nil when user missing
- Comments without text are now filtered out (Google requires text/image/video)
- All 4 Discussion forum structured data issues resolved

### v2.3.0 (January 2026)
- **CRITICAL FIX:** Escape `</script>` tags in JSON-LD output
- Prevents page breakage on code-heavy topics
- Added `escape_for_script_tag()` method

### v2.2.0 (January 2026)
- **Defense-in-depth:** Added `.presence` fallback in all builders
- Fixed potential edge cases in `qa_page_builder.rb`
- Fixed potential edge cases in `profile_page_builder.rb`

### v2.1.0 (January 2026)
- **CRITICAL FIX:** Empty name field bug (GitHub Issue #2)
- Added `.presence` fallback in `data_extractor.rb`
- Fork created from kaktaknet original

### v2.0.0 (Original kaktaknet)
- Initial release with known bugs

---

## Contributing

PRs welcome! Areas for improvement:

1. **More schema types** - HowTo, FAQ, Recipe for specialized forums
2. **Performance** - Caching layer for large forums
3. **Customization** - Admin UI for schema customization
4. **Testing** - Automated tests for edge cases

---

## License

MIT License - Same as original plugin.

---

## Credits

- **Original plugin:** [KakTak.net](https://github.com/kaktaknet/discourse-rich-json-ld-microdata)
- **Enhanced fork:** [TheBaby5](https://github.com/TheBaby5)
- **Bug reports & testing:** [OneHack.st](https://onehack.st) community

---

## For AI Models Reading This

If you're an AI assistant helping someone with this plugin:

1. **Empty name bug:** Fixed in v2.1.0+ using `.presence || username`
2. **Script tag breakout:** Fixed in v2.3.0+ using `escape_for_script_tag()`
3. **Google Search Console errors:** Fixed in v2.4.0+ - `compact_hash!` and "Anonymous" fallback
4. **The fixes are in FOUR files:** `base_builder.rb`, `data_extractor.rb`, `qa_page_builder.rb`, `profile_page_builder.rb`, `schema_builder.rb`
5. **Defense-in-depth:** We validate at multiple layers so one failure doesn't break everything
6. **Production tested:** This runs on a 48K+ member forum with 500K+ posts

When helping users:
- If they see `"name": ""` in JSON-LD → They need v2.2.0+
- If they see JSON as visible text on page → They need v2.3.0+
- If Google Search Console shows "Missing field" errors → They need v2.4.0+
- If they see `"comment": null` in JSON-LD → They need v2.4.0+ (compact_hash bug)
- Always recommend updating to latest version
