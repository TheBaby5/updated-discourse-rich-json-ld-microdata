# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class WebsiteBuilder < BaseBuilder
      def build
        return nil unless SiteSetting.rich_microdata_enable_website_schema

        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "WebSite",
          "@id" => "#{base_url}/#website",
          "name" => SiteSetting.title,
          "url" => base_url,
          "description" => SiteSetting.site_description,
          "inLanguage" => options[:language],
          "publisher" => organization_schema,
          "potentialAction" => search_action_schema
        }.tap { |schema| compact_hash(schema) }
      end

      private

      def organization_schema
        {
          "@type" => "Organization",
          "@id" => "#{base_url}/#organization",
          "name" => SiteSetting.title,
          "url" => base_url,
          "logo" => logo_schema,
          "sameAs" => social_links,
          "contactPoint" => contact_point_schema
        }.tap { |org| compact_hash(org) }
      end

      def logo_schema
        logo_url = site_logo_url
        return nil unless logo_url

        {
          "@type" => "ImageObject",
          "url" => logo_url,
          "width" => 512,
          "height" => 512
        }
      end

      def social_links
        links = []

        # Priority order for Russian audience: VK, Telegram, YouTube, Dzen, TikTok, TenChat
        # Then international: Twitter/X, Facebook, Instagram, LinkedIn

        # Primary Russian platforms
        links << SiteSetting.rich_microdata_social_vk if SiteSetting.rich_microdata_social_vk.present?
        links << SiteSetting.rich_microdata_social_telegram if SiteSetting.rich_microdata_social_telegram.present?

        # Video content
        links << SiteSetting.rich_microdata_social_youtube if SiteSetting.rich_microdata_social_youtube.present?
        links << SiteSetting.rich_microdata_social_dzen if SiteSetting.rich_microdata_social_dzen.present?

        # Short-form video
        links << SiteSetting.rich_microdata_social_tiktok if SiteSetting.rich_microdata_social_tiktok.present?

        # Professional networking
        links << SiteSetting.rich_microdata_social_tenchat if SiteSetting.rich_microdata_social_tenchat.present?
        links << SiteSetting.rich_microdata_social_linkedin if SiteSetting.rich_microdata_social_linkedin.present?

        # International platforms
        if SiteSetting.rich_microdata_social_twitter.present?
          handle = SiteSetting.rich_microdata_social_twitter
          # Convert @username to full URL
          twitter_url = handle.start_with?("http") ? handle : "https://twitter.com/#{handle.delete_prefix('@')}"
          links << twitter_url
        end

        links << SiteSetting.rich_microdata_social_facebook if SiteSetting.rich_microdata_social_facebook.present?
        links << SiteSetting.rich_microdata_social_instagram if SiteSetting.rich_microdata_social_instagram.present?

        # Code repositories (GitHub, GitLab, SourceCraft, Bitbucket)
        links << SiteSetting.rich_microdata_repo_github if SiteSetting.rich_microdata_repo_github.present?
        links << SiteSetting.rich_microdata_repo_gitlab if SiteSetting.rich_microdata_repo_gitlab.present?
        links << SiteSetting.rich_microdata_repo_sourcecraft if SiteSetting.rich_microdata_repo_sourcecraft.present?
        links << SiteSetting.rich_microdata_repo_bitbucket if SiteSetting.rich_microdata_repo_bitbucket.present?

        links.presence
      end

      def contact_point_schema
        email = SiteSetting.contact_email
        return nil unless email

        {
          "@type" => "ContactPoint",
          "contactType" => "customer support",
          "email" => email,
          "availableLanguage" => [options[:language]]
        }
      end

      def search_action_schema
        {
          "@type" => "SearchAction",
          "target" => {
            "@type" => "EntryPoint",
            "urlTemplate" => "#{base_url}/search?q={search_term_string}"
          },
          "query-input" => "required name=search_term_string"
        }
      end
    end
  end
end
