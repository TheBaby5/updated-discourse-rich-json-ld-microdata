# frozen_string_literal: true

module DiscourseRichMicrodata
  module Builders
    class QAPageBuilder < BaseBuilder
      def build
        content_type = SiteSetting.rich_microdata_content_type || 'discussion'

        # For Q&A, wrap in QAPage. For others, use content type directly.
        if content_type == 'qa'
          build_qa_page
        else
          build_content_page(content_type)
        end
      end

      private

      def build_qa_page
        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => "QAPage",
          "@id" => data[:url],
          "url" => data[:url],
          "name" => data[:title],
          "description" => data[:excerpt],
          "inLanguage" => options[:language],
          "isPartOf" => website_reference,
          "breadcrumb" => breadcrumb_reference,
          "mainEntity" => question_entity
        }.tap { |schema| compact_hash(schema) }
      end

      def build_content_page(content_type)
        type_map = {
          'discussion' => 'DiscussionForumPosting',
          'article' => 'Article',
          'news' => 'NewsArticle',
          'review' => 'Review',
          'recipe' => 'Recipe',
          'event' => 'Event'
        }

        main_type = type_map[content_type] || 'DiscussionForumPosting'

        {
          "@context" => SCHEMA_CONTEXT,
          "@type" => main_type,
          "@id" => data[:url],
          "url" => data[:url],
          "headline" => data[:title],
          "name" => data[:title],
          "description" => data[:excerpt],
          "inLanguage" => options[:language],
          "isPartOf" => website_reference,
          "breadcrumb" => breadcrumb_reference,
          "articleBody" => data.dig(:posts, 0, :raw),
          "datePublished" => iso8601_date(data[:created_at]),
          "dateModified" => iso8601_date(data[:updated_at]),
          "author" => person_schema(data[:author]),
          "commentCount" => [data[:posts_count] - 1, 0].max,
          "interactionStatistic" => question_statistics,
          "comment" => comments_schemas(content_type)
        }.tap { |schema| compact_hash(schema) }
      end

      def question_entity
        first_post = data[:posts]&.first
        return nil unless first_post

        {
          "@type" => "Question",
          "@id" => "#{data[:url]}#question",
          "name" => data[:title],
          "text" => first_post[:raw],
          "dateCreated" => iso8601_date(data[:created_at]),
          "dateModified" => iso8601_date(data[:updated_at]),
          "upvoteCount" => data[:like_count] || 0,
          "answerCount" => [data[:posts_count] - 1, 0].max,
          "commentCount" => [data[:posts_count] - 1, 0].max,
          "author" => person_schema(data[:author]),
          "about" => tags_schemas,
          "interactionStatistic" => question_statistics,
          "acceptedAnswer" => accepted_answer_schema,
          "suggestedAnswer" => suggested_answers_schemas
        }.tap { |q| compact_hash(q) }
      end

      def accepted_answer_schema
        accepted_id = data[:accepted_answer_post_id]
        return nil unless accepted_id

        accepted_post = data[:posts]&.find { |p| p[:id] == accepted_id.to_i }
        return nil unless accepted_post

        answer_schema(accepted_post, is_accepted: true)
      end

      def suggested_answers_schemas
        answers = data[:posts]&.reject { |p| p[:is_first_post] }
        return nil if answers.blank?

        if data[:accepted_answer_post_id]
          answers = answers.reject { |p| p[:id] == data[:accepted_answer_post_id].to_i }
        end

        max_answers = SiteSetting.rich_microdata_max_answers
        answers = answers.first(max_answers)

        return nil if answers.empty?

        answers.map { |post| answer_schema(post) }
      end

      def answer_schema(post, is_accepted: false)
        {
          "@type" => "Answer",
          "@id" => "#{post[:url]}#answer",
          "url" => post[:url],
          "text" => post[:raw],
          "dateCreated" => iso8601_date(post[:created_at]),
          "dateModified" => iso8601_date(post[:updated_at]),
          "upvoteCount" => post[:like_count] || 0,
          "author" => person_schema(post[:author]),
          "comment" => nested_comments_schemas(post)
        }.tap do |answer|
          answer["acceptedAnswerStatus"] = "Accepted" if is_accepted
          compact_hash(answer)
        end
      end

      def nested_comments_schemas(parent_post)
        replies = data[:posts]&.select { |p| p[:reply_to_post_number] == parent_post[:post_number] }
        return nil if replies.blank?

        max_comments = SiteSetting.rich_microdata_max_comments
        replies = replies.first(max_comments)

        replies.map do |reply|
          {
            "@type" => "Comment",
            "@id" => "#{reply[:url]}#comment",
            "url" => reply[:url],
            "text" => truncate_text(reply[:raw], 500),
            "dateCreated" => iso8601_date(reply[:created_at]),
            "upvoteCount" => reply[:like_count] || 0,
            "author" => person_schema(reply[:author]),
            "parentItem" => { "@id" => "#{parent_post[:url]}#answer" }
          }.tap { |comment| compact_hash(comment) }
        end
      end

      def person_schema(user_data)
        return nil unless user_data

        {
          "@type" => "Person",
          "@id" => "#{user_data[:url]}#person",
          "name" => user_data[:name],
          "identifier" => user_data[:username],
          "url" => user_data[:url],
          "image" => user_data[:avatar_url] ? avatar_image_schema(user_data[:avatar_url]) : nil,
          "interactionStatistic" => person_statistics(user_data)
        }.tap { |person| compact_hash(person) }
      end

      def avatar_image_schema(url)
        {
          "@type" => "ImageObject",
          "url" => url,
          "width" => 240,
          "height" => 240
        }
      end

      def person_statistics(user_data)
        return nil unless SiteSetting.rich_microdata_include_user_stats

        [
          interaction_counter("WriteAction", user_data[:topic_count], t('interaction_stats.created_topics')),
          interaction_counter("CommentAction", user_data[:post_count], t('interaction_stats.written_replies')),
          interaction_counter("LikeAction", user_data[:likes_received], t('interaction_stats.received_likes'))
        ].compact
      end

      def tags_schemas
        return nil if data[:tags].blank?

        data[:tags].map do |tag|
          {
            "@type" => "Thing",
            "@id" => tag[:url],
            "name" => tag[:name],
            "description" => tag[:description]
          }.tap { |t| compact_hash(t) }
        end
      end

      def question_statistics
        [
          interaction_counter("ViewAction", data[:views]),
          interaction_counter("LikeAction", data[:like_count]),
          interaction_counter("CommentAction", data[:reply_count])
        ].compact
      end

      def interaction_counter(type, count, description = nil)
        return nil if count.nil? || count.zero?

        {
          "@type" => "InteractionCounter",
          "interactionType" => "https://schema.org/#{type}",
          "userInteractionCount" => count,
          "description" => description
        }.tap { |counter| compact_hash(counter) }
      end

      def comments_schemas(content_type)
        replies = data[:posts]&.reject { |p| p[:is_first_post] }
        return nil if replies.blank?

        max_comments = SiteSetting.rich_microdata_max_answers
        replies = replies.first(max_comments)

        return nil if replies.empty?

        # For review type, replies can also be Review. For others, use Comment.
        comment_type = (content_type == 'review') ? 'Comment' : 'Comment'

        replies.map do |post|
          {
            "@type" => comment_type,
            "@id" => "#{post[:url]}#comment",
            "url" => post[:url],
            "text" => post[:raw],
            "dateCreated" => iso8601_date(post[:created_at]),
            "dateModified" => iso8601_date(post[:updated_at]),
            "upvoteCount" => post[:like_count] || 0,
            "author" => person_schema(post[:author])
          }.tap { |comment| compact_hash(comment) }
        end
      end

      def website_reference
        { "@id" => "#{base_url}/#website" }
      end

      def breadcrumb_reference
        { "@id" => "#{data[:url]}#breadcrumb" }
      end
    end
  end
end
