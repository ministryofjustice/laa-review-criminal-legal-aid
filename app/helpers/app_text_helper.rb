module AppTextHelper
  def action_text(key, options = {})
    named_text(:actions, key, options)
  end

  def confirm_text(key, options = {})
    named_text(:confirmations, key, options)
  end

  def hint_text(key, options = {})
    named_text(:hint_texts, key, options)
  end

  def label_text(key, options = {})
    named_text(:labels, key, options)
  end

  def label_text_with_subject(key, subject, options = {}, subject_appended: true)
    options[:count] = /client.+partner/.match?(subject) ? 2 : 1
    options[:subject] = subject unless subject_appended
    label = label_text(key, options)
    if subject_appended
      return current_crime_application.applicant.has_partner == 'yes' ? "#{label}: #{subject}" : label
    end

    label
  end

  def value_text(key, options = {})
    named_text(:values, key, options)
  end

  def thead_text(key, options = {})
    named_text(:table_headings, key, options)
  end

  def warning_text(key, options = {})
    named_text(:warnings, key, options)
  end

  private

  def named_text(text_type, key, options = {})
    namespace = controller.try(:text_namespace)
    scope = [namespace, text_type, *options.delete(:scope)]

    I18n.t(key, scope:, **options)
  end
end
