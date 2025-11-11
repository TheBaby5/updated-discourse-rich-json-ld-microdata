# Usage Guide: Discourse Rich JSON-LD Microdata Plugin

Complete guide with practical examples for using this plugin effectively.

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Generated Markup Examples](#generated-markup-examples)
- [Rails Console Usage](#rails-console-usage)
- [Advanced Configuration](#advanced-configuration)
- [Integration Examples](#integration-examples)
- [Performance Optimization](#performance-optimization)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)

---

## 🚀 Quick Start

### 1. Install Plugin

```bash
cd /var/discourse
git clone https://github.com/kaktaknet/discourse-rich-json-ld-microdata.git plugins/discourse-rich-json-ld-microdata
./launcher rebuild app
```

### 2. Enable in Admin Panel

Navigate to: **Admin → Settings → Plugins → discourse-rich-json-ld-microdata**

```
✅ rich_microdata_enabled: true
```

### 3. Verify Installation

Open any topic and view source (Ctrl+U), look for:

```html
<meta property="og:type" content="article" data-rich-microdata="og">
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "QAPage",
  ...
}
</script>
```

If you see `data-rich-microdata` attribute, the plugin is working!

---

## 📄 Generated Markup Examples

### For Topic Pages

When you open a topic like `/t/how-to-optimize-postgresql/123`, the plugin generates:

#### Open Graph Tags

```html
<meta property="og:site_name" content="My Forum" data-rich-microdata="og">
<meta property="og:type" content="article" data-rich-microdata="og">
<meta property="og:title" content="How to optimize PostgreSQL queries?" data-rich-microdata="og">
<meta property="og:url" content="https://forum.com/t/how-to-optimize-postgresql/123" data-rich-microdata="og">
<meta property="og:description" content="My queries are running 3.5 seconds, need help..." data-rich-microdata="og">
<meta property="og:image" content="https://forum.com/uploads/postgres-logo.jpg" data-rich-microdata="og">
<meta property="og:image:width" content="1200" data-rich-microdata="og">
<meta property="og:image:height" content="630" data-rich-microdata="og">
<meta property="og:locale" content="en_US" data-rich-microdata="og">
<meta property="article:published_time" content="2025-01-15T10:30:00Z" data-rich-microdata="og">
<meta property="article:modified_time" content="2025-01-16T14:20:00Z" data-rich-microdata="og">
<meta property="article:author" content="https://forum.com/u/john-dev" data-rich-microdata="og">
<meta property="article:section" content="Database" data-rich-microdata="og">
<meta property="article:tag" content="postgresql" data-rich-microdata="og">
<meta property="article:tag" content="performance" data-rich-microdata="og">
<meta property="article:tag" content="sql" data-rich-microdata="og">
```

#### Twitter Card Tags

```html
<meta name="twitter:card" content="summary_large_image" data-rich-microdata="twitter">
<meta name="twitter:site" content="@yourforum" data-rich-microdata="twitter">
<meta name="twitter:title" content="How to optimize PostgreSQL queries?" data-rich-microdata="twitter">
<meta name="twitter:description" content="My queries are running 3.5 seconds..." data-rich-microdata="twitter">
<meta name="twitter:image" content="https://forum.com/uploads/postgres-logo.jpg" data-rich-microdata="twitter">
<meta name="twitter:creator" content="@yourforum" data-rich-microdata="twitter">
<meta name="twitter:label1" content="Replies" data-rich-microdata="twitter">
<meta name="twitter:data1" content="12" data-rich-microdata="twitter">
<meta name="twitter:label2" content="Author" data-rich-microdata="twitter">
<meta name="twitter:data2" content="John Developer" data-rich-microdata="twitter">
```

#### JSON-LD QAPage Schema

```json
{
  "@context": "https://schema.org",
  "@type": "QAPage",
  "@id": "https://forum.com/t/how-to-optimize-postgresql/123",
  "url": "https://forum.com/t/how-to-optimize-postgresql/123",
  "name": "How to optimize PostgreSQL queries?",
  "description": "My queries are running 3.5 seconds, need help optimizing...",
  "inLanguage": "en-US",
  "isPartOf": {
    "@id": "https://forum.com/#website"
  },
  "breadcrumb": {
    "@id": "https://forum.com/t/how-to-optimize-postgresql/123#breadcrumb"
  },
  "mainEntity": {
    "@type": "Question",
    "@id": "https://forum.com/t/how-to-optimize-postgresql/123#question",
    "name": "How to optimize PostgreSQL queries?",
    "text": "My queries are running 3.5 seconds on a table with 10M rows. Using simple SELECT with WHERE clause. How can I speed this up?",
    "answerCount": 12,
    "upvoteCount": 45,
    "dateCreated": "2025-01-15T10:30:00Z",
    "dateModified": "2025-01-16T14:20:00Z",
    "author": {
      "@type": "Person",
      "@id": "https://forum.com/u/john-dev#person",
      "name": "John Developer",
      "url": "https://forum.com/u/john-dev",
      "image": {
        "@type": "ImageObject",
        "url": "https://forum.com/user_avatar/john-dev/240/123.png",
        "width": 240,
        "height": 240
      },
      "interactionStatistic": [
        {
          "@type": "InteractionCounter",
          "interactionType": "https://schema.org/WriteAction",
          "userInteractionCount": 87,
          "description": "Created topics"
        },
        {
          "@type": "InteractionCounter",
          "interactionType": "https://schema.org/CommentAction",
          "userInteractionCount": 523,
          "description": "Written replies"
        },
        {
          "@type": "InteractionCounter",
          "interactionType": "https://schema.org/LikeAction",
          "userInteractionCount": 1249,
          "description": "Received likes"
        }
      ]
    },
    "about": [
      {
        "@type": "Thing",
        "@id": "https://forum.com/tag/postgresql",
        "name": "postgresql",
        "description": "PostgreSQL database management system"
      },
      {
        "@type": "Thing",
        "@id": "https://forum.com/tag/performance",
        "name": "performance",
        "description": "Performance optimization topics"
      }
    ],
    "interactionStatistic": [
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/ViewAction",
        "userInteractionCount": 2834
      },
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/LikeAction",
        "userInteractionCount": 45
      },
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/CommentAction",
        "userInteractionCount": 12
      }
    ],
    "acceptedAnswer": {
      "@type": "Answer",
      "@id": "https://forum.com/t/how-to-optimize-postgresql/123/5#answer",
      "url": "https://forum.com/t/how-to-optimize-postgresql/123/5",
      "text": "Create a composite index on your WHERE columns: CREATE INDEX idx_table_cols ON your_table (col1, col2); This should bring your query time down to ~50ms.",
      "dateCreated": "2025-01-15T11:15:00Z",
      "upvoteCount": 89,
      "acceptedAnswerStatus": "Accepted",
      "author": {
        "@type": "Person",
        "name": "Maria DB Expert",
        "url": "https://forum.com/u/maria-db"
      }
    },
    "suggestedAnswer": [
      {
        "@type": "Answer",
        "@id": "https://forum.com/t/how-to-optimize-postgresql/123/2#answer",
        "url": "https://forum.com/t/how-to-optimize-postgresql/123/2",
        "text": "Have you checked if you have indexes on those columns?",
        "dateCreated": "2025-01-15T10:45:00Z",
        "upvoteCount": 12,
        "author": {
          "@type": "Person",
          "name": "Bob Backend",
          "url": "https://forum.com/u/bob-backend"
        }
      }
    ]
  }
}
```

#### BreadcrumbList Schema

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "@id": "https://forum.com/t/how-to-optimize-postgresql/123#breadcrumb",
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": "https://forum.com"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Database",
      "item": "https://forum.com/c/database/5"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "PostgreSQL",
      "item": "https://forum.com/c/database/postgresql/8"
    },
    {
      "@type": "ListItem",
      "position": 4,
      "name": "How to optimize PostgreSQL queries?",
      "item": "https://forum.com/t/how-to-optimize-postgresql/123"
    }
  ]
}
```

### For Category Pages

When viewing `/c/database/5`:

```json
{
  "@context": "https://schema.org",
  "@type": "CollectionPage",
  "@id": "https://forum.com/c/database/5",
  "url": "https://forum.com/c/database/5",
  "name": "Database",
  "description": "All things databases - SQL, NoSQL, optimization, design patterns",
  "inLanguage": "en-US",
  "isPartOf": {
    "@id": "https://forum.com/#website"
  },
  "about": {
    "@type": "Thing",
    "name": "Database",
    "description": "All things databases - SQL, NoSQL, optimization, design patterns"
  },
  "hasPart": [
    {
      "@type": "CollectionPage",
      "@id": "https://forum.com/c/database/postgresql/8",
      "url": "https://forum.com/c/database/postgresql/8",
      "name": "PostgreSQL",
      "description": "PostgreSQL-specific topics",
      "isPartOf": {
        "@id": "https://forum.com/c/database/5"
      },
      "numberOfItems": 234
    },
    {
      "@type": "CollectionPage",
      "@id": "https://forum.com/c/database/mysql/9",
      "url": "https://forum.com/c/database/mysql/9",
      "name": "MySQL",
      "description": "MySQL and MariaDB discussions",
      "isPartOf": {
        "@id": "https://forum.com/c/database/5"
      },
      "numberOfItems": 187
    }
  ],
  "numberOfItems": 456,
  "interactionStatistic": [
    {
      "@type": "InteractionCounter",
      "interactionType": "https://schema.org/WriteAction",
      "userInteractionCount": 456,
      "description": "Number of topics"
    },
    {
      "@type": "InteractionCounter",
      "interactionType": "https://schema.org/CommentAction",
      "userInteractionCount": 3421,
      "description": "Number of replies"
    }
  ]
}
```

### For User Profile Pages

When viewing `/u/john-dev`:

```json
{
  "@context": "https://schema.org",
  "@type": "ProfilePage",
  "@id": "https://forum.com/u/john-dev",
  "url": "https://forum.com/u/john-dev",
  "name": "Profile John Developer",
  "inLanguage": "en-US",
  "isPartOf": {
    "@id": "https://forum.com/#website"
  },
  "mainEntity": {
    "@type": "Person",
    "@id": "https://forum.com/u/john-dev#person",
    "identifier": "john-dev",
    "name": "John Developer",
    "url": "https://forum.com/u/john-dev",
    "image": {
      "@type": "ImageObject",
      "url": "https://forum.com/user_avatar/john-dev/240/123.png",
      "width": 240,
      "height": 240
    },
    "description": "Full-stack developer specializing in PostgreSQL and Ruby on Rails. 10+ years experience.",
    "sameAs": [
      "https://github.com/johndev",
      "https://twitter.com/johndev"
    ],
    "interactionStatistic": [
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/WriteAction",
        "userInteractionCount": 87,
        "description": "Created topics"
      },
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/CommentAction",
        "userInteractionCount": 523,
        "description": "Written replies"
      },
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/LikeAction",
        "userInteractionCount": 1249,
        "description": "Received likes"
      },
      {
        "@type": "InteractionCounter",
        "interactionType": "https://schema.org/ReadAction",
        "userInteractionCount": 8734,
        "description": "Read posts"
      }
    ],
    "dateCreated": "2023-05-12T08:30:00Z"
  }
}
```

### WebSite Global Schema

Present on all pages:

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "@id": "https://forum.com/#website",
  "name": "My Developer Forum",
  "url": "https://forum.com",
  "description": "A community for developers to discuss programming, databases, and best practices",
  "inLanguage": "en-US",
  "publisher": {
    "@type": "Organization",
    "@id": "https://forum.com/#organization",
    "name": "My Developer Forum",
    "url": "https://forum.com",
    "logo": {
      "@type": "ImageObject",
      "url": "https://forum.com/uploads/logo.png",
      "width": 512,
      "height": 512
    },
    "contactPoint": {
      "@type": "ContactPoint",
      "contactType": "customer support",
      "email": "support@forum.com",
      "availableLanguage": ["en-US"]
    }
  },
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://forum.com/search?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
```

---

## 🔧 Rails Console Usage

### Extract Data from Objects

```ruby
# Extract topic data
topic = Topic.find(123)
topic_view = TopicView.new(topic)
data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic, topic_view)

puts JSON.pretty_generate(data)
```

**Output:**
```json
{
  "title": "How to optimize PostgreSQL queries?",
  "url": "https://forum.com/t/how-to-optimize-postgresql/123",
  "excerpt": "My queries are running 3.5 seconds...",
  "image_url": "https://forum.com/uploads/postgres-logo.jpg",
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-16T14:20:00Z",
  "views": 2834,
  "like_count": 45,
  "reply_count": 12,
  "posts_count": 13,
  "author": {
    "name": "John Developer",
    "username": "john-dev",
    "url": "https://forum.com/u/john-dev",
    "avatar_url": "https://forum.com/user_avatar/john-dev/240/123.png",
    "topic_count": 87,
    "post_count": 523,
    "likes_received": 1249
  },
  "category": {
    "name": "PostgreSQL",
    "url": "https://forum.com/c/database/postgresql/8",
    "description": "PostgreSQL-specific topics",
    "parent_category": {
      "name": "Database",
      "url": "https://forum.com/c/database/5"
    }
  },
  "tags": [
    {
      "name": "postgresql",
      "url": "https://forum.com/tag/postgresql"
    }
  ],
  "posts": [...],
  "accepted_answer_post_id": 5
}
```

### Generate Markup for Specific Objects

```ruby
# Generate for topic
topic = Topic.find(123)
result = MetaGeneratorService.generate_for_topic(topic)

puts result[:head]    # Open Graph + Twitter Cards
puts result[:body]    # JSON-LD schemas

# Generate for category
category = Category.find(5)
result = MetaGeneratorService.generate_for_category(category)

# Generate for user
user = User.find_by(username: 'john-dev')
result = MetaGeneratorService.generate_for_user(user)
```

### Test Specific Builders

```ruby
# Test Open Graph builder
data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic)
og_builder = DiscourseRichMicrodata::Builders::OpenGraphBuilder.new(data, { language_og: 'en_US' })
puts og_builder.build

# Test QAPage builder
qa_builder = DiscourseRichMicrodata::Builders::QAPageBuilder.new(data, { language: 'en-US' })
puts JSON.pretty_generate(qa_builder.build)
```

### Cache Management

```ruby
# Check cache statistics
stats = MetaGeneratorService.cache_stats
puts stats
# => { topics: 1247, categories: 15, users: 234, total_size: "7.5 MB" }

# Clear specific cache
MetaGeneratorService.invalidate_topic_cache(123)
MetaGeneratorService.invalidate_category_cache(5)
MetaGeneratorService.invalidate_user_cache(456)

# Clear all cache
MetaGeneratorService.clear_all_cache

# Warm up cache for popular topics
Topic.where("views > ?", 1000).find_each do |topic|
  MetaGeneratorService.generate_for_topic(topic)
  sleep 0.1  # Throttle
end
```

### Language Detection Testing

```ruby
# Test language detection
controller = TopicsController.new

# Mock user locale
user = User.find_by(username: 'ivan')
user.update(locale: 'ru')
controller.instance_variable_set(:@current_user, user)

# Generate with user's language
result = MetaGeneratorService.generate_for_topic(topic, nil, controller)

# Check if Russian translations are used
puts result[:body]  # Should contain "Главная" instead of "Home"
```

### Performance Benchmarking

```ruby
require 'benchmark'

topic = Topic.find(123)

# Benchmark cold vs warm cache
Benchmark.bm(20) do |x|
  x.report("Cold (first call):") do
    Rails.cache.clear
    MetaGeneratorService.generate_for_topic(topic)
  end

  x.report("Warm (cached):") do
    MetaGeneratorService.generate_for_topic(topic)
  end

  x.report("Warm (100x):") do
    100.times { MetaGeneratorService.generate_for_topic(topic) }
  end
end
```

**Expected output:**
```
                          user     system      total        real
Cold (first call):    0.040000   0.003000   0.043000 (  0.052341)
Warm (cached):        0.001000   0.000000   0.001000 (  0.002103)
Warm (100x):          0.120000   0.005000   0.125000 (  0.210582)
```

---

## ⚙️ Advanced Configuration

### Custom Image Fallback

**Problem:** Topics without images show empty `og:image` tag.

**Solution:**

1. Upload default image to `/uploads/`
2. Set in Admin → Settings:
   ```
   rich_microdata_og_image_default: https://forum.com/uploads/default-og.jpg
   ```

3. Verify:
   ```ruby
   topic = Topic.find_by(title: "No Image Topic")
   data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic)
   puts data[:image_url]
   # => "https://forum.com/uploads/default-og.jpg"
   ```

### Twitter Card Configuration

**Enable large image cards:**

1. Set Twitter handle:
   ```
   rich_microdata_twitter_site: @yourforum
   ```

2. Verify topics with images show `summary_large_image`:
   ```ruby
   builder = DiscourseRichMicrodata::Builders::TwitterCardBuilder.new(data, {})
   result = builder.build
   result["twitter:card"]  # => "summary_large_image"
   ```

### Adjust Answer/Comment Limits

**To show more answers in QAPage:**

```
rich_microdata_max_answers: 20  # Default: 10
rich_microdata_max_comments: 10  # Default: 5
```

**Impact:**
- More answers = larger JSON-LD
- Recommended: 10-20 answers, 5-10 comments per answer
- Monitor page size

### Performance Tuning

**Increase cache TTL for high-traffic sites:**

```
rich_microdata_cache_ttl: 7200  # 2 hours instead of 1
```

**Trade-off:**
- ✅ Faster page loads
- ✅ Less Redis operations
- ❌ Stale data for up to 2 hours after edits

**Invalidate cache on edits:**

Plugin automatically invalidates cache when:
- Topic is edited
- Post is created/edited
- Category is updated
- User profile is updated

### Disable Specific Features

**Disable breadcrumbs:**
```
rich_microdata_enable_breadcrumbs: false
```

**Disable WebSite schema:**
```
rich_microdata_enable_website_schema: false
```

**Disable user statistics:**
```
rich_microdata_include_user_stats: false
```

---

## 🔗 Integration Examples

### With Discourse Solved Plugin

Plugin automatically detects solved answers:

```ruby
# When topic has accepted answer
topic = Topic.find(123)
topic.custom_fields['accepted_answer_post_id']  # => 5

# Generated QAPage includes acceptedAnswer
result = MetaGeneratorService.generate_for_topic(topic)
schema = JSON.parse(result[:body].match(/<script type="application\/ld\+json">(.*?)<\/script>/m)[1])

schema['mainEntity']['acceptedAnswer']['acceptedAnswerStatus']
# => "Accepted"
```

### With Discourse Tagging

Tags become Schema.org Thing entities:

```ruby
topic = Topic.find(123)
topic.tags.pluck(:name)  # => ["postgresql", "performance", "sql"]

# Generated schema includes:
{
  "about": [
    {
      "@type": "Thing",
      "@id": "https://forum.com/tag/postgresql",
      "name": "postgresql"
    }
  ]
}
```

### With Custom User Fields

Add social links to ProfilePage:

```ruby
# Add custom user field for GitHub username
user = User.find_by(username: 'john-dev')
user.custom_fields['github_username'] = 'johndev'
user.save!

# Modify lib/discourse_rich_microdata/data_extractor.rb:
def extract_user_data(user)
  # ... existing code ...
  data[:social_links] = []
  data[:social_links] << "https://github.com/#{user.custom_fields['github_username']}" if user.custom_fields['github_username']
  data
end

# Generated ProfilePage includes:
{
  "sameAs": [
    "https://github.com/johndev"
  ]
}
```

---

## ⚡ Performance Optimization

### Cache Warm-Up Script

```ruby
# script/warm_cache.rb
puts "Warming up microdata cache..."

# Popular topics (views > 1000)
Topic.where("views > ?", 1000).order(views: :desc).limit(100).find_each do |topic|
  MetaGeneratorService.generate_for_topic(topic)
  print "."
end

# All categories
Category.find_each do |category|
  MetaGeneratorService.generate_for_category(category)
  print "."
end

puts "\nCache warmed up!"
```

Run on deploy:
```bash
cd /var/discourse
./launcher enter app
rails runner script/warm_cache.rb
```

### Monitor Cache Hit Rate

```ruby
# Add to lib/discourse_rich_microdata/meta_generator_service.rb

def self.cache_hit_rate
  hits = Rails.cache.read('rich_microdata:cache_hits') || 0
  misses = Rails.cache.read('rich_microdata:cache_misses') || 0
  total = hits + misses

  return 0 if total == 0
  (hits.to_f / total * 100).round(2)
end

def self.increment_cache_hit
  Rails.cache.increment('rich_microdata:cache_hits', 1, initial: 0)
end

def self.increment_cache_miss
  Rails.cache.increment('rich_microdata:cache_misses', 1, initial: 0)
end
```

Check in console:
```ruby
MetaGeneratorService.cache_hit_rate
# => 97.34
```

### Reduce Memory Usage

For very large forums:

1. **Limit answer extraction:**
   ```
   rich_microdata_max_answers: 5
   rich_microdata_max_comments: 3
   ```

2. **Disable user stats:**
   ```
   rich_microdata_include_user_stats: false
   ```

3. **Use shorter cache TTL:**
   ```
   rich_microdata_cache_ttl: 1800  # 30 minutes
   ```

---

## 🐛 Troubleshooting Common Issues

### Issue: Markup Not Appearing

**Symptoms:** View source shows no `data-rich-microdata` tags

**Solution:**

1. Check if plugin is enabled:
   ```ruby
   SiteSetting.rich_microdata_enabled
   # => Should be true
   ```

2. Check for errors in logs:
   ```bash
   tail -f log/production.log | grep RichMicrodata
   ```

3. Try generating manually:
   ```ruby
   topic = Topic.find(123)
   result = MetaGeneratorService.generate_for_topic(topic)
   puts result
   ```

4. If error occurs, enable debug mode:
   ```ruby
   SiteSetting.rich_microdata_debug_mode = true
   ```

### Issue: Images Not Showing in Social Shares

**Symptoms:** Facebook/Twitter show no image preview

**Solution:**

1. Verify image URL is absolute:
   ```ruby
   data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic)
   data[:image_url]
   # => Should start with https://
   ```

2. Check image is accessible:
   ```bash
   curl -I https://forum.com/uploads/image.jpg
   # => Should return 200 OK
   ```

3. Verify image dimensions:
   - Minimum: 200x200px
   - Recommended: 1200x630px
   - Format: JPG or PNG

4. Clear social media cache:
   - [Facebook Debugger](https://developers.facebook.com/tools/debug/)
   - [Twitter Card Validator](https://cards-dev.twitter.com/validator)

### Issue: Schema Validation Errors

**Symptoms:** Schema.org validator shows errors

**Solution:**

1. Test with validator:
   - Copy JSON-LD from page source
   - Paste into https://validator.schema.org/

2. Common fixes:

   **Missing required field:**
   ```ruby
   # Edit lib/discourse_rich_microdata/builders/qa_page_builder.rb
   # Ensure all required fields are present
   def question_entity
     {
       "@type" => "Question",
       "name" => data[:title],  # Required
       "text" => data[:excerpt],  # Required
       "answerCount" => data[:posts_count] - 1  # Required
     }
   end
   ```

   **Invalid date format:**
   ```ruby
   # Use iso8601_date helper
   "dateCreated" => iso8601_date(data[:created_at])
   # NOT: data[:created_at].to_s
   ```

3. Check for nil values:
   ```ruby
   # Always use compact_hash
   schema.tap { |s| compact_hash(s) }
   ```

### Issue: Cache Not Invalidating

**Symptoms:** Edits don't reflect in generated markup

**Solution:**

1. Check if cache hooks are registered:
   ```ruby
   # In plugin.rb, verify these exist:
   on(:topic_edited) { ... }
   on(:post_created) { ... }
   ```

2. Manually clear cache:
   ```ruby
   MetaGeneratorService.clear_all_cache
   ```

3. Verify Redis is working:
   ```ruby
   Rails.cache.write('test', 'value')
   Rails.cache.read('test')
   # => "value"
   ```

### Issue: Language Not Detected

**Symptoms:** Wrong language in markup

**Solution:**

1. Check language detection:
   ```ruby
   controller = TopicsController.new
   DiscourseRichMicrodata::LanguageHelper.detect_language(controller)
   # => "en-US" or "ru-RU"
   ```

2. Verify user locale:
   ```ruby
   user = User.find_by(username: 'ivan')
   user.effective_locale
   # => "ru"
   ```

3. Check site default:
   ```ruby
   SiteSetting.default_locale
   # => "en"
   ```

4. Test translation:
   ```ruby
   I18n.locale = :ru
   I18n.t('discourse_rich_microdata.breadcrumb.home')
   # => "Главная"
   ```

---

## 📈 Success Metrics

### Google Search Console

After 2-4 weeks, check:

1. **Rich Results Report:**
   - Search Console → Enhancements → Rich Results
   - Look for QAPage, BreadcrumbList entries

2. **Structured Data Report:**
   - Verify no errors
   - Check coverage (should be ~100%)

3. **Performance:**
   - Compare CTR before/after plugin
   - Monitor impressions for rich snippets

### Social Media Analytics

Track social shares:

1. **Facebook Insights:**
   - Check preview quality
   - Monitor engagement on shared links

2. **Twitter Analytics:**
   - Track card impressions
   - Monitor link clicks

### Internal Monitoring

```ruby
# Monthly report
puts "Microdata Generation Report"
puts "==========================="
puts "Topics cached: #{MetaGeneratorService.cache_stats[:topics]}"
puts "Categories cached: #{MetaGeneratorService.cache_stats[:categories]}"
puts "Users cached: #{MetaGeneratorService.cache_stats[:users]}"
puts "Cache hit rate: #{MetaGeneratorService.cache_hit_rate}%"
puts "Total cache size: #{MetaGeneratorService.cache_stats[:total_size]}"
```

---

## 🎓 Best Practices

1. **Always use high-quality images** (1200x630px) for topics
2. **Write detailed topic titles** (helps with Schema.org name field)
3. **Enable Solved plugin** for better acceptedAnswer detection
4. **Use descriptive category descriptions**
5. **Encourage users to fill out bios** (improves Person schema)
6. **Monitor cache hit rate** (aim for >95%)
7. **Warm up cache after deploys**
8. **Test markup with validators** before major releases

---

## 📚 Further Reading

- [Schema.org QAPage](https://schema.org/QAPage)
- [Google Rich Results Guidelines](https://developers.google.com/search/docs/appearance/structured-data/qapage)
- [Open Graph Best Practices](https://ogp.me/)
- [Twitter Card Documentation](https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards)
