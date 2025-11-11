# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class BreadcrumbBuilder < BaseBuilder
      def build
        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "BreadcrumbList",
          "@id" => "#{current_url}#breadcrumb",
          "itemListElement" => breadcrumb_items
        }
      end

      private

      def breadcrumb_items
        items = [home_item]

        case detect_page_type
        when :topic
          items.concat(category_chain_items)
          items << topic_item
        when :category
          items.concat(category_chain_items)
        when :user
          items << user_item
        end

        items
      end

      def detect_page_type
        return :topic if data[:title] && data[:posts]
        return :category if data[:topic_count]
        return :user if data[:username]
        :default
      end

      def home_item
        {
          "@type" => "ListItem",
          "position" => 1,
          "name" => t('breadcrumb.home'),
          "item" => base_url
        }
      end

      def category_chain_items
        items = []
        position = 2

        category_chain.each do |category|
          items << {
            "@type" => "ListItem",
            "position" => position,
            "name" => category[:name],
            "item" => category[:url]
          }
          position += 1
        end

        items
      end

      def topic_item
        {
          "@type" => "ListItem",
          "position" => breadcrumb_position_for_topic,
          "name" => data[:title],
          "item" => data[:url]
        }
      end

      def user_item
        {
          "@type" => "ListItem",
          "position" => 2,
          "name" => data[:name],
          "item" => data[:url]
        }
      end

      def category_chain
        return [] unless data[:category]

        chain = []
        current = data[:category]

        while current
          chain.unshift(current)
          current = current[:parent_category]
        end

        chain
      end

      def breadcrumb_position_for_topic
        2 + category_chain.length
      end

      def current_url
        data[:url] || base_url
      end
    end
  end
end
