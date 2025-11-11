# frozen_string_literal: true

module DiscourseRichMicrodata
  module LanguageHelper
    def self.detect_language(controller = nil)
      # Priority: user preference > site default > browser locale
      detect_user_language(controller) ||
        detect_site_language ||
        detect_browser_language(controller) ||
        "en-US"
    end

    def self.detect_user_language(controller)
      return nil unless controller

      current_user = controller.try(:current_user)
      return nil unless current_user

      locale = current_user.effective_locale
      locale ? normalize_locale(locale) : nil
    end

    def self.detect_site_language
      locale = SiteSetting.default_locale
      locale ? normalize_locale(locale) : nil
    end

    def self.detect_browser_language(controller)
      return nil unless controller

      accept_language = controller.request.env["HTTP_ACCEPT_LANGUAGE"]
      return nil unless accept_language

      # Parse Accept-Language header (e.g., "ru-RU,ru;q=0.9,en-US;q=0.8")
      locales = accept_language.split(",").map do |lang|
        lang.split(";").first.strip
      end

      normalize_locale(locales.first) if locales.any?
    end

    def self.normalize_locale(locale)
      # Convert underscore to hyphen (en_US -> en-US)
      locale = locale.to_s.gsub("_", "-")

      # Ensure proper case (en-us -> en-US)
      parts = locale.split("-")
      parts[0] = parts[0].downcase
      parts[1] = parts[1].upcase if parts[1]

      parts.join("-")
    end

    def self.language_code(controller = nil)
      detect_language(controller).split("-").first
    end

    def self.locale_for_og(controller = nil)
      detect_language(controller).gsub("-", "_")
    end

    def self.i18n_locale(controller = nil)
      language_code(controller).to_sym
    end

    # Extract all language options at once to avoid passing controller to cache
    def self.extract_language_options(controller = nil)
      {
        language: detect_language(controller),
        language_og: locale_for_og(controller),
        language_code: language_code(controller),
        i18n_locale: i18n_locale(controller)
      }
    end
  end
end
