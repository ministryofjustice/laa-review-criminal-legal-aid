class CustomFailureApp < Devise::FailureApp
  private

  # Override to handle array-based i18n messages used for notification banners.
  # Devise 5 calls start_with? on the translated message, which fails when
  # the translation returns an Array instead of a String.
  def i18n_message(default = nil)
    message = warden_message || default || :unauthenticated

    return message.to_s unless message.is_a?(Symbol)

    options = i18n_options(base_i18n_options(message))
    msg = I18n.t(:"#{scope}.#{message}", **options)

    return msg if msg.is_a?(Array)

    capitalize_message(msg)
  end

  def base_i18n_options(message)
    {
      resource_name: scope,
      scope: 'devise.failure',
      default: [message],
      authentication_keys: human_authentication_keys.join(I18n.t(:'support.array.words_connector'))
    }
  end

  def human_authentication_keys
    auth_keys = scope_class.authentication_keys
    (auth_keys.respond_to?(:keys) ? auth_keys.keys : auth_keys).map do |key|
      scope_class.human_attribute_name(key).downcase_first
    end
  end

  def capitalize_message(msg)
    msg.start_with?(human_authentication_keys.first) ? msg.upcase_first : msg
  end
end
