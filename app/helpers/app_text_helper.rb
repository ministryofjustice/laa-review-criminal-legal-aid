module AppTextHelper
  def action_text(key, options = {})
    named_text(:actions, key, options)
  end

  def thead_text(key, options = {})
    named_text(:table_headings, key, options)
  end

  private

  def named_text(text_type, key, options = {})
    namespace = controller.try(:text_namespace)
    I18n.t(key, scope: [namespace, text_type].compact, **options)
  end
end
