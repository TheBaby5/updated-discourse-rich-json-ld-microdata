# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class OpenGraphBuilder < BaseBuilder
      def build
        tags = []

        case detect_page_type
        when :topic
          tags = build_topic_tags
        when :category
          tags = build_category_tags
        when :user
          tags = build_user_tags
        else
          tags = build_default_tags
        end

        render_tags(tags)
      end

      private

      def detect_page_type
        return :topic if data[:title] && data[:posts]
        return :category if data[:topic_count]
        return :user if data[:username]
        :default
      end

      def build_topic_tags
        # Only unique tags that Discourse doesn't generate
        # Discourse already generates: og:site_name, og:type, og:title, og:url, og:description,
        # og:image, article:published_time, og:article:section
        tags = {
          "og:locale" => options[:language_og],  # Unique: locale information
          "og:image:width" => "1200",  # Unique: image dimensions
          "og:image:height" => "630",
          "og:image:type" => "image/jpeg",  # Unique: image MIME type
          "og:image:alt" => data[:title]  # Unique: alt text for accessibility
        }

        # Add alternate locales if configured
        alternate_locales = parse_alternate_locales
        if alternate_locales.any?
          tags["og:locale:alternate"] = alternate_locales
        end

        # Add article-specific tags for article type content
        if determine_og_type == "article"
          tags.merge!(build_article_tags)
        end

        tags
      end

      def build_article_tags
        # Discourse already generates: article:published_time, og:article:section
        article_tags = {
          "article:modified_time" => iso8601_date(data[:updated_at]),  # Unique: modification date
          "article:author" => data.dig(:author, :url)  # Unique: author URL
        }

        # Add tags from topic (Discourse doesn't generate article:tag)
        if data[:tags].present? && data[:tags].is_a?(Array)
          # Multiple article:tag properties - one per tag
          data[:tags].each do |tag|
            article_tags["article:tag"] ||= []
            article_tags["article:tag"] << tag
          end
        end

        article_tags
      end

      def parse_alternate_locales
        # Parse alternate locales from settings (comma-separated)
        # Returns array of locale codes
        locales_setting = SiteSetting.rich_microdata_og_alternate_locales
        return [] if locales_setting.blank?

        # Split by comma, strip whitespace, and filter out empty values
        locales_setting.split(',').map(&:strip).reject(&:blank?)
      end

      def build_category_tags
        # Only unique tags - Discourse already generates og:site_name, og:type, og:title,
        # og:url, og:description, og:image for categories
        tags = {
          "og:locale" => options[:language_og]  # Unique: locale information
        }

        # Add alternate locales if configured
        alternate_locales = parse_alternate_locales
        if alternate_locales.any?
          tags["og:locale:alternate"] = alternate_locales
        end

        tags
      end

      def build_user_tags
        # Enhanced profile tags (Discourse has basic support)
        # We add profile-specific metadata that Discourse doesn't generate
        tags = {
          "og:type" => "profile",  # Enhanced: specific profile type
          "og:locale" => options[:language_og],  # Unique: locale information
          "profile:username" => data[:username],  # Unique: structured profile data
          "profile:first_name" => extract_first_name(data[:name]),
          "profile:last_name" => extract_last_name(data[:name])
        }

        # Add alternate locales if configured
        alternate_locales = parse_alternate_locales
        if alternate_locales.any?
          tags["og:locale:alternate"] = alternate_locales
        end

        tags
      end

      def build_default_tags
        # Only unique tags - Discourse already generates all basic OG tags for homepage
        tags = {
          "og:locale" => options[:language_og]  # Unique: locale information
        }

        # Add alternate locales if configured
        alternate_locales = parse_alternate_locales
        if alternate_locales.any?
          tags["og:locale:alternate"] = alternate_locales
        end

        tags
      end

      def render_tags(tags_hash)
        html = []

        tags_hash.each do |property, content|
          next if content.nil? || (content.respond_to?(:empty?) && content.empty?)

          if content.is_a?(Array)
            content.each do |value|
              html << render_single_tag(property, value)
            end
          else
            html << render_single_tag(property, content)
          end
        end

        html.join("\n")
      end

      def render_single_tag(property, content)
        %(<meta property="#{escape_html(property)}" content="#{escape_html(content.to_s)}">)
      end

      def determine_og_type
        content_type = SiteSetting.rich_microdata_content_type || 'discussion'

        # Map content types to Open Graph types
        # Open Graph Protocol supports: article, website, profile, video, music, book
        # ❌ qa, news, review, recipe are NOT standard OG types → use "article"
        # ❌ event is NOT standard OG type → use "website"
        case content_type
        when 'discussion', 'event'
          'website'  # General discussions and events are better represented as website
        when 'qa', 'article', 'news', 'review', 'recipe'
          'article'  # Q&A, articles, news, reviews, recipes use article type
        else
          'article'  # Default fallback
        end
      end

      def extract_first_name(full_name)
        return nil unless full_name
        parts = full_name.split(" ")
        parts.first
      end

      def extract_last_name(full_name)
        return nil unless full_name
        parts = full_name.split(" ")
        parts.length > 1 ? parts[1..-1].join(" ") : nil
      end
    end
  end
end
