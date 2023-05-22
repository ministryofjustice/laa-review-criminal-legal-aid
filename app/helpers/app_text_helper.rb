module AppTextHelper
<<<<<<< HEAD
=======
  def confirm_text(key, options = {})
    named_text(:confirmations, key, options)
  end

  def warning_text(key, options = {})
    named_text(:warnings, key, options)
  end

>>>>>>> 094a05b (CRIMRE-320-manage-invitations)
  def action_text(key, options = {})
    named_text(:actions, key, options)
  end

  def thead_text(key, options = {})
    named_text(:table_headings, key, options)
  end

<<<<<<< HEAD
  private

  def named_text(text_type, key, options = {})
    namespace = controller.try(:text_namespace)
=======
  def label_text(key, options = {})
    named_text(:labels, key, options)
  end

  def hint_text(key, options = {})
    named_text(:hint_texts, key, options)
  end

  private

  def named_text(text_type, key, options = {})
    namespace = controller.text_namespace
>>>>>>> 094a05b (CRIMRE-320-manage-invitations)
    I18n.t(key, scope: [namespace, text_type].compact, **options)
  end
end
