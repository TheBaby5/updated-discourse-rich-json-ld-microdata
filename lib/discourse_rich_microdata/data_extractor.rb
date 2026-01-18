# frozen_string_literal: true

require 'erb'
require 'cgi'

module DiscourseRichMicrodata
  # Single source of truth for all builders
  class DataExtractor
    attr_reader :object, :context

    def initialize(object, context = {})
      @object = object
      @context = context
    end

    def self.extract_topic_data(topic, topic_view = nil)
      first_post = topic.first_post
      category = topic.category

      {
        id: topic.id,
        title: topic.title,
        slug: topic.slug,
        url: "#{Discourse.base_url}#{topic.relative_url}",
        created_at: topic.created_at,
        updated_at: topic.last_posted_at || topic.updated_at,
        excerpt: first_post&.excerpt(300) || topic.excerpt,
        raw_content: first_post&.raw,
        image_url: extract_topic_image(topic),
        author: extract_user_data(topic.user),
        category: category ? extract_category_data(category) : nil,
        tags: topic.tags.map { |tag| extract_tag_data(tag) },
        views: topic.views,
        posts_count: topic.posts_count,
        like_count: topic.like_count,
        reply_count: topic.reply_count,
        posts: topic_view ? extract_posts_data(topic_view) : [],
        accepted_answer_post_id: topic.custom_fields["accepted_answer_post_id"],
        closed: topic.closed,
        archived: topic.archived,
        pinned: topic.pinned_at.present?
      }
    end

    def self.extract_category_data(category)
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        url: "#{Discourse.base_url}/c/#{ERB::Util.url_encode(category.slug)}/#{category.id}",
        description: category.description_text,
        color: category.color,
        parent_category_id: category.parent_category_id,
        # Use shallow extraction to prevent infinite recursion
        parent_category: category.parent_category ? extract_category_data_shallow(category.parent_category) : nil,
        subcategories: category.subcategories.map { |sub| extract_category_data_shallow(sub) },
        topic_count: category.topic_count,
        post_count: category.post_count
      }
    end

    # Shallow category extraction without parent/subcategories (prevents recursion)
    def self.extract_category_data_shallow(category)
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        url: "#{Discourse.base_url}/c/#{ERB::Util.url_encode(category.slug)}/#{category.id}",
        description: category.description_text,
        color: category.color,
        topic_count: category.topic_count,
        post_count: category.post_count
      }
    end

    def self.extract_user_data(user)
      return nil unless user

      profile = user.user_profile
      user_stat = user.user_stat

      # FIX: Use .presence to handle empty strings properly
      # When user.name is "" (empty string), it should fallback to username
      # Original bug: user.name || user.username didn't handle empty strings
      display_name = user.name.presence || user.username

      {
        id: user.id,
        username: user.username,
        name: display_name,
        url: "#{Discourse.base_url}/u/#{ERB::Util.url_encode(user.username)}",
        avatar_url: user_avatar_url(user),
        title: user.title,
        bio: profile&.bio_processed ? ActionView::Base.full_sanitizer.sanitize(profile.bio_processed) : nil,
        location: profile&.location,
        website: profile&.website,
        topic_count: user.topic_count,
        post_count: user.post_count,
        likes_given: user_stat&.likes_given || 0,
        likes_received: user_stat&.likes_received || 0,
        days_visited: user_stat&.days_visited || 0,
        posts_read_count: user_stat&.posts_read_count || 0,
        time_read: user_stat&.time_read || 0,
        created_at: user.created_at,
        last_seen_at: user.last_seen_at,
        trust_level: user.trust_level,
        admin: user.admin?,
        moderator: user.moderator?
      }
    end

    def self.extract_posts_data(topic_view)
      posts = topic_view.posts.includes(:user).order(:post_number)
      max_posts = SiteSetting.rich_microdata_max_answers + 1

      posts.limit(max_posts).map do |post|
        {
          id: post.id,
          post_number: post.post_number,
          url: "#{Discourse.base_url}#{topic_view.topic.relative_url}/#{post.post_number}",
          raw: post.raw,
          cooked: post.cooked,
          excerpt: post.excerpt(500),
          created_at: post.created_at,
          updated_at: post.updated_at,
          reply_to_post_number: post.reply_to_post_number,
          like_count: post.like_count,
          author: extract_user_data(post.user),
          is_first_post: post.post_number == 1
        }
      end
    end

    def self.extract_tag_data(tag)
      {
        id: tag.id,
        name: tag.name,
        url: "#{Discourse.base_url}/tag/#{ERB::Util.url_encode(tag.name)}",
        description: tag.description,
        topic_count: tag.public_topic_count  # Use public_topic_count (topic_count doesn't exist)
      }
    end

    # Priority: topic image_url > first image in post > default setting > site logo
    def self.extract_topic_image(topic)
      return topic.image_url if topic.image_url.present?

      first_post = topic.first_post
      if first_post
        doc = Nokogiri::HTML(first_post.cooked)
        img = doc.css('img').first
        return "#{Discourse.base_url}#{img['src']}" if img && img['src']
      end

      default_image = SiteSetting.rich_microdata_og_image_default
      return default_image if default_image.present?

      begin
        logo = Upload.find_by(id: SiteSetting.logo)
        logo_url = logo&.url
        return absolute_url(logo_url) if logo_url.present?
      rescue => e
        Rails.logger.warn "[RichMicrodata] Error getting logo in extract_topic_image: #{e.message}"
      end

      # Fallback to default Discourse logo
      absolute_url("/images/discourse-logo-sketch-small.png")
    end

    def self.user_avatar_url(user, size = 240)
      return nil unless user.avatar_template

      template = user.avatar_template
      template = template.gsub("{size}", size.to_s)

      template.start_with?("http") ? template : "#{Discourse.base_url}#{template}"
    end

    def self.iso8601_date(time)
      time&.iso8601
    end

    def self.absolute_url(path)
      return path if path.to_s.start_with?("http")
      "#{Discourse.base_url}#{path}"
    end

    # URL encode path component (handles Cyrillic and special characters)
    def self.encode_path_component(component)
      ERB::Util.url_encode(component.to_s)
    end

    def self.truncate_text(text, length = 300)
      return nil if text.blank?

      text = ActionView::Base.full_sanitizer.sanitize(text) if text.include?("<")
      text.truncate(length, omission: "...", separator: " ")
    end
  end
end
