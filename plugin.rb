# frozen_string_literal: true

# name: discourse-rich-json-ld-microdata
# about: Enhances Discourse meta tags with comprehensive Open Graph and Schema.org JSON-LD markup for better SEO and LLM coverage
# version: 2.4.0
# authors: TheBaby5 (fork maintainer), KakTak.net (original)
# url: https://github.com/TheBaby5/updated-discourse-rich-json-ld-microdata
# license: MIT
# required_version: 2.7.0

enabled_site_setting :rich_microdata_enabled

# Define module before loading classes
module ::DiscourseRichMicrodata
  PLUGIN_NAME = "discourse-rich-json-ld-microdata"
end

after_initialize do
  module ::DiscourseRichMicrodata
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseRichMicrodata
    end
  end

  require_relative "lib/discourse_rich_microdata/language_helper"
  require_relative "lib/discourse_rich_microdata/data_extractor"
  require_relative "lib/discourse_rich_microdata/builders/base_builder"
  require_relative "lib/discourse_rich_microdata/builders/open_graph_builder"
  require_relative "lib/discourse_rich_microdata/builders/twitter_card_builder"
  require_relative "lib/discourse_rich_microdata/builders/schema_builder"
  require_relative "lib/discourse_rich_microdata/builders/qa_page_builder"
  require_relative "lib/discourse_rich_microdata/builders/breadcrumb_builder"
  require_relative "lib/discourse_rich_microdata/builders/website_builder"
  require_relative "lib/discourse_rich_microdata/builders/collection_page_builder"
  require_relative "lib/discourse_rich_microdata/builders/profile_page_builder"
  require_relative "lib/discourse_rich_microdata/coordinator"
  require_relative "app/services/meta_generator_service"

  # Register HTML builders - correct approach per Discourse best practices
  # Generate HTML directly in register_html_builder, not via after_action

  # For both application.html.erb and crawler.html.erb
  ['server:before-head-close', 'server:before-head-close-crawler'].each do |outlet|
    register_html_builder(outlet) do |controller|
      begin
        next "" unless SiteSetting.rich_microdata_enabled

        result = nil
        is_crawler = outlet.include?('crawler')

        Rails.logger.info "[RichMicrodata] HTML builder (#{outlet}) started for #{controller.class.name}"

        # Extract language options BEFORE caching (don't cache controller!)
        language_options = DiscourseRichMicrodata::LanguageHelper.extract_language_options(controller)

        # Generate metadata based on controller type
        if controller.is_a?(TopicsController)
          topic_view = controller.instance_variable_get(:@topic_view)
          next "" unless topic_view&.topic

          Rails.logger.info "[RichMicrodata] Generating for topic #{topic_view.topic.id}"
          result = MetaGeneratorService.generate_for_topic(topic_view.topic, topic_view, language_options)
          Rails.logger.info "[RichMicrodata] Generated for topic #{topic_view.topic.id}, crawler: #{is_crawler}, head size: #{result[:head]&.length || 0}"

        elsif controller.is_a?(CategoriesController)
          category = controller.instance_variable_get(:@category)
          next "" unless category

          Rails.logger.info "[RichMicrodata] Generating for category #{category.id}"
          result = MetaGeneratorService.generate_for_category(category, language_options)
          Rails.logger.info "[RichMicrodata] Generated for category #{category.id}, crawler: #{is_crawler}"

        elsif controller.is_a?(UsersController)
          user = controller.instance_variable_get(:@user)
          next "" unless user

          Rails.logger.info "[RichMicrodata] Generating for user #{user.id}"
          result = MetaGeneratorService.generate_for_user(user, language_options)
          Rails.logger.info "[RichMicrodata] Generated for user #{user.id}, crawler: #{is_crawler}"
        end

        next "" unless result && result[:head].present?

        # No cleanup_script needed - we only generate unique tags that don't duplicate Discourse
        Rails.logger.info "[RichMicrodata] Returning HTML (#{result[:head].length} chars), crawler: #{is_crawler}"
        result[:head].html_safe

      rescue => e
        Rails.logger.error "[RichMicrodata] CRITICAL ERROR in HTML builder (#{outlet}): #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n") if e.backtrace
        ""
      end
    end
  end

  on(:topic_edited) do |topic, user|
    Rails.cache.delete("rich_microdata:topic:#{topic.id}")
  end

  on(:post_created) do |post, opts, user|
    Rails.cache.delete("rich_microdata:topic:#{post.topic_id}")
  end

  on(:post_edited) do |post, topic_changed|
    Rails.cache.delete("rich_microdata:topic:#{post.topic_id}")
  end

  on(:category_updated) do |category|
    Rails.cache.delete("rich_microdata:category:#{category.id}")
  end

  on(:user_updated) do |user|
    Rails.cache.delete("rich_microdata:user:#{user.id}")
  end

  Rails.logger.info "[RichMicrodata] Plugin initialized successfully"
  Rails.logger.info "[RichMicrodata] Enabled: #{SiteSetting.rich_microdata_enabled}"
end
