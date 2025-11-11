# frozen_string_literal: true

class MetaGeneratorService
  class << self
    def generate_for_topic(topic, topic_view = nil, language_options = {})
      cache_key = "rich_microdata:topic:#{topic.id}:#{topic.updated_at.to_i}"

      Rails.cache.fetch(cache_key, expires_in: cache_ttl) do
        data = DiscourseRichMicrodata::DataExtractor.extract_topic_data(topic, topic_view)
        DiscourseRichMicrodata::Coordinator.new(data, language_options: language_options).generate
      end
    rescue => e
      log_error(e, "generate_for_topic")
      { head: "", body: "" }
    end

    def generate_for_category(category, language_options = {})
      cache_key = "rich_microdata:category:#{category.id}:#{category.updated_at.to_i}"

      Rails.cache.fetch(cache_key, expires_in: cache_ttl) do
        data = DiscourseRichMicrodata::DataExtractor.extract_category_data(category)
        DiscourseRichMicrodata::Coordinator.new(data, language_options: language_options).generate
      end
    rescue => e
      log_error(e, "generate_for_category")
      { head: "", body: "" }
    end

    def generate_for_user(user, language_options = {})
      cache_key = "rich_microdata:user:#{user.id}:#{user.updated_at.to_i}"

      Rails.cache.fetch(cache_key, expires_in: cache_ttl) do
        data = DiscourseRichMicrodata::DataExtractor.extract_user_data(user)
        DiscourseRichMicrodata::Coordinator.new(data, language_options: language_options).generate
      end
    rescue => e
      log_error(e, "generate_for_user")
      { head: "", body: "" }
    end

    def invalidate_topic_cache(topic_id)
      pattern = "rich_microdata:topic:#{topic_id}:*"
      delete_by_pattern(pattern)
    end

    def invalidate_category_cache(category_id)
      pattern = "rich_microdata:category:#{category_id}:*"
      delete_by_pattern(pattern)
    end

    def invalidate_user_cache(user_id)
      pattern = "rich_microdata:user:#{user_id}:*"
      delete_by_pattern(pattern)
    end

    def clear_all_cache
      pattern = "rich_microdata:*"
      delete_by_pattern(pattern)
    end

    def cache_stats
      {
        topics: count_cached_items("rich_microdata:topic:*"),
        categories: count_cached_items("rich_microdata:category:*"),
        users: count_cached_items("rich_microdata:user:*"),
        total_size: approximate_cache_size
      }
    end

    private

    def cache_ttl
      SiteSetting.rich_microdata_cache_ttl.seconds
    end

    def delete_by_pattern(pattern)
      if Rails.cache.respond_to?(:delete_matched)
        Rails.cache.delete_matched(pattern)
      else
        keys = Rails.cache.redis.keys(pattern)
        keys.each { |key| Rails.cache.delete(key) }
      end
    end

    def count_cached_items(pattern)
      if Rails.cache.respond_to?(:redis)
        Rails.cache.redis.keys(pattern).count
      else
        0
      end
    end

    def approximate_cache_size
      "N/A"
    end

    def debug(message)
      return unless SiteSetting.rich_microdata_debug_mode

      Rails.logger.debug "[MetaGeneratorService] #{message}"
    end

    def log_error(error, context = "")
      Rails.logger.error "[MetaGeneratorService] ERROR in #{context}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n") if error.backtrace
    end
  end
end
