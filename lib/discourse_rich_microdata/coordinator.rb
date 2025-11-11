# frozen_string_literal: true

module DiscourseRichMicrodata
  class Coordinator
    attr_reader :data, :options

    def initialize(data, options = {})
      @data = data
      @options = options

      # Use pre-extracted language options if provided
      enrich_options_with_language(options[:language_options])
    end

    def generate
      begin
        {
          head: generate_head_tags,
          body: generate_body_tags
        }
      rescue => e
        log_error(e)
        { head: "", body: "" }
      end
    end

    private

    def generate_head_tags
      parts = []
      parts << generate_llms_meta_tags  # Static LLM indexing tags
      parts << generate_open_graph
      parts << generate_twitter_card
      parts << generate_schema  # Include JSON-LD in head for crawler compatibility
      parts.compact.join("\n")
    rescue => e
      log_error(e, "Head Tags")
      ""
    end

    def generate_body_tags
      # Schema is now included in head for crawler compatibility
      # Body tags are no longer needed as crawler layout lacks body hooks
      ""
    rescue => e
      log_error(e, "Body Tags")
      ""
    end

    def generate_llms_meta_tags
      base_url = Discourse.base_url
      [
        %(<meta name="llms-txt" content="#{base_url}/llms.txt">),
        %(<meta name="llms-full-txt" content="#{base_url}/llms-full.txt">),
        %(<meta name="llms-sitemaps-txt" content="#{base_url}/sitemaps.txt">)
      ].join("\n")
    rescue => e
      log_error(e, "LLMS Meta Tags")
      nil
    end

    def generate_open_graph
      Builders::OpenGraphBuilder.new(data, options).build
    rescue => e
      log_error(e, "OpenGraphBuilder")
      nil
    end

    def generate_twitter_card
      Builders::TwitterCardBuilder.new(data, options).build
    rescue => e
      log_error(e, "TwitterCardBuilder")
      nil
    end

    def generate_schema
      Builders::SchemaBuilder.new(data, options).build
    rescue => e
      log_error(e, "SchemaBuilder")
      nil
    end

    def detect_page_type
      return :topic if data[:title] && data[:posts]
      return :category if data[:topic_count]
      return :user if data[:username]
      :default
    end

    def debug(message)
      return unless SiteSetting.rich_microdata_debug_mode

      Rails.logger.debug "[RichMicrodata::Coordinator] #{message}"
    end

    def log_error(error, context = "")
      Rails.logger.error "[RichMicrodata::Coordinator] ERROR in #{context}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n") if error.backtrace
    end

    def enrich_options_with_language(language_options = nil)
      if language_options && language_options.is_a?(Hash)
        # Use pre-extracted language options (from plugin.rb)
        @options[:language] = language_options[:language] || "en-US"
        @options[:language_og] = language_options[:language_og] || "en_US"
        @options[:language_code] = language_options[:language_code] || "en"
        @options[:i18n_locale] = language_options[:i18n_locale] || :en
      else
        # Fallback to defaults (should not happen in normal flow)
        @options[:language] = "en-US"
        @options[:language_og] = "en_US"
        @options[:language_code] = "en"
        @options[:i18n_locale] = :en
      end
    end
  end
end
