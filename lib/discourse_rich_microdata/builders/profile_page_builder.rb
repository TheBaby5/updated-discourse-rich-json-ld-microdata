# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class ProfilePageBuilder < BaseBuilder
      def build
        # FIXED: Defense-in-depth - always ensure valid name even if data is cached/stale
        display_name = data[:name].presence || data[:username]

        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "ProfilePage",
          "@id" => data[:url],
          "url" => data[:url],
          "name" => t('profile_page.title', user_name: display_name),
          "inLanguage" => options[:language],
          "isPartOf" => { "@id" => "#{base_url}/#website" },
          "mainEntity" => person_schema
        }
      end

      private

      def person_schema
        # FIXED: Defense-in-depth - always ensure valid name even if data is cached/stale
        display_name = data[:name].presence || data[:username]

        {
          "@type" => "Person",
          "@id" => "#{data[:url]}#person",
          "identifier" => data[:username],
          "name" => display_name,
          "url" => data[:url],
          "image" => avatar_image_schema,
          "description" => data[:bio],
          "sameAs" => social_links,
          "interactionStatistic" => person_statistics,
          "dateCreated" => iso8601_date(data[:created_at])
        }.tap { |person| compact_hash(person) }
      end

      def avatar_image_schema
        return nil unless data[:avatar_url]

        {
          "@type" => "ImageObject",
          "url" => data[:avatar_url],
          "width" => 240,
          "height" => 240
        }
      end

      def social_links
        links = []
        links << data[:website] if data[:website].present?
        links.presence
      end

      def person_statistics
        return nil unless SiteSetting.rich_microdata_include_user_stats

        [
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/WriteAction",
            "userInteractionCount" => data[:topic_count],
            "description" => t('interaction_stats.created_topics')
          },
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/CommentAction",
            "userInteractionCount" => data[:post_count],
            "description" => t('interaction_stats.written_replies')
          },
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/LikeAction",
            "userInteractionCount" => data[:likes_received],
            "description" => t('interaction_stats.received_likes')
          },
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/ReadAction",
            "userInteractionCount" => data[:posts_read_count],
            "description" => t('interaction_stats.read_posts')
          }
        ].compact
      end
    end
  end
end
