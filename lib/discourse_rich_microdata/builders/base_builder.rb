# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    # Base class for all builders
    class BaseBuilder
      SCHEMA_CONTEXT = "https://schema.org"

      attr_reader :data, :options

      def initialize(data, options = {})
        @data = data
        @options = options
      end

      def build
        raise NotImplementedError, "Subclass must implement #build method"
      end

      protected

      def base_url
        Discourse.base_url
      end

      def absolute_url(path)
        DataExtractor.absolute_url(path)
      end

      def site_logo_url
        begin
          logo = Upload.find_by(id: SiteSetting.logo)
          logo_url = logo&.url
          return absolute_url(logo_url) if logo_url.present?
        rescue => e
          Rails.logger.warn "[RichMicrodata] Error getting logo: #{e.message}"
        end

        # Fallback to default Discourse logo
        absolute_url("/images/discourse-logo-sketch-small.png")
      end

      def iso8601_date(time)
        DataExtractor.iso8601_date(time)
      end

      def escape_html(text)
        ERB::Util.html_escape(text)
      end

      def sanitize_html(html)
        ActionView::Base.full_sanitizer.sanitize(html)
      end

      def truncate_text(text, length = 300)
        DataExtractor.truncate_text(text, length)
      end

      def entity_id(url)
        "#{url}#entity"
      end

      def entity_reference(url)
        { "@id" => entity_id(url) }
      end

      # FIXED: Use reject! to modify hash in place (was returning new hash, discarding it)
      # This fixes the Google Search Console "missing field" errors where null values
      # were being kept in the schema instead of removed
      def compact_hash!(hash)
        hash.reject! { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
        hash
      end

      # Alias for backwards compatibility (some code might still call compact_hash)
      alias_method :compact_hash, :compact_hash!

      def t(key, opts = {})
        I18n.t("discourse_rich_microdata.#{key}", **opts.merge(locale: options[:i18n_locale] || :en))
      end

      def validate_required_fields(hash, *fields)
        fields.each do |field|
          raise ArgumentError, "Missing required field: #{field}" unless hash[field].present?
        end
      end

      def debug(message)
        return unless SiteSetting.rich_microdata_debug_mode

        Rails.logger.debug "[RichMicrodata] #{self.class.name}: #{message}"
      end

      def log_error(error, context = {})
        Rails.logger.error "[RichMicrodata] #{self.class.name} ERROR: #{error.message}"
        Rails.logger.error "Context: #{context.inspect}"
        Rails.logger.error error.backtrace.join("\n") if error.backtrace
      end
    end
  end
end
