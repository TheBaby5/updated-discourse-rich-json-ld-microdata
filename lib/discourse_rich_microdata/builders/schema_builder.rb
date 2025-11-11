# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    # Combines all JSON-LD schemas into one or more blocks
    class SchemaBuilder < BaseBuilder
      def build
        schemas = collect_schemas
        return "" if schemas.empty?

        render_schema_tags(schemas)
      end

      private

      def collect_schemas
        schemas = []

        if SiteSetting.rich_microdata_enable_website_schema
          website_schema = WebsiteBuilder.new(data, options).build
          schemas << website_schema if website_schema
        end

        if SiteSetting.rich_microdata_enable_breadcrumbs
          breadcrumb_schema = BreadcrumbBuilder.new(data, options).build
          schemas << breadcrumb_schema if breadcrumb_schema
        end

        main_schema = build_main_schema
        schemas << main_schema if main_schema

        schemas.compact
      end

      def build_main_schema
        case detect_page_type
        when :topic
          QAPageBuilder.new(data, options).build
        when :category
          CollectionPageBuilder.new(data, options).build
        when :user
          ProfilePageBuilder.new(data, options).build
        else
          nil
        end
      end

      def detect_page_type
        return :topic if data[:title] && data[:posts]
        return :category if data[:topic_count]
        return :user if data[:username]
        :default
      end

      def render_schema_tags(schemas)
        if schemas.length == 1
          render_single_schema(schemas.first)
        else
          render_multiple_schemas(schemas)
        end
      end

      def render_single_schema(schema)
        json = JSON.pretty_generate(schema)
        %(<script type="application/ld+json">\n#{json}\n</script>)
      end

      def render_multiple_schemas(schemas)
        json = JSON.pretty_generate(schemas)
        %(<script type="application/ld+json">\n#{json}\n</script>)
      end
    end
  end
end
