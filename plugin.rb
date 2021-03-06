# frozen_string_literal: true

# name: discourse-categories-suppressed-only-normal
# about: Suppress categories from latest topics page only normal.
# version: 0.1
# url: https://github.com/vinothkannans/discourse-categories-suppressed

after_initialize do

  if TopicQuery.respond_to?(:results_filter_callbacks)
    remove_suppressed_category_topics = Proc.new do |list_type, result, user, options|
      category_ids = (SiteSetting.categories_suppressed_from_latest.presence || "").split("|").map(&:to_i)
      if category_ids.blank? || list_type != :latest || options[:category] || options[:tags] || user.nil?
        result
      else
        begin
          result.where("topics.category_id NOT IN (#{category_ids.join(",")}) OR tu.notification_level IN (2,3)")
        rescue => e
          result
        end
      end
    end

    TopicQuery.results_filter_callbacks << remove_suppressed_category_topics
  end

end
