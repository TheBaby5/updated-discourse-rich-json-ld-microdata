# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class CollectionPageBuilder < BaseBuilder
      def build
        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "CollectionPage",
          "@id" => data[:url],
          "url" => data[:url],
          "name" => data[:name],
          "description" => data[:description],
          "inLanguage" => options[:language],
          "isPartOf" => { "@id" => "#{base_url}/#website" },
          "about" => about_schema,
          "hasPart" => subcategories_schema,
          "numberOfItems" => data[:topic_count],
          "interactionStatistic" => category_statistics
        }.tap { |schema| compact_hash(schema) }
      end

      private

      def about_schema
        {
          "@type" => "Thing",
          "name" => data[:name],
          "description" => data[:description]
        }.tap { |about| compact_hash(about) }
      end

      def subcategories_schema
        return nil if data[:subcategories].blank?

        data[:subcategories].map do |subcat|
          {
            "@type" => "CollectionPage",
            "@id" => subcat[:url],
            "url" => subcat[:url],
            "name" => subcat[:name],
            "description" => subcat[:description],
            "isPartOf" => { "@id" => data[:url] },
            "numberOfItems" => subcat[:topic_count]
          }.tap { |sub| compact_hash(sub) }
        end
      end

      def category_statistics
        [
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/WriteAction",
            "userInteractionCount" => data[:topic_count],
            "description" => t('interaction_stats.number_of_topics')
          },
          {
            "@type" => "InteractionCounter",
            "interactionType" => "https://schema.org/CommentAction",
            "userInteractionCount" => data[:post_count],
            "description" => t('interaction_stats.number_of_replies')
          }
        ].compact
      end
    end
  end
end
