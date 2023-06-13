# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :_key, :certificate, :client_id, :client_secret,
  :oid, :otp, :passw, :pkce, :salt, :secret, :ssn,
  :tenant_id, :token, :crypt,

  # Attributes relating to an application
  # It does partial matching (i.e. `telephone_number` is covered by `phone`)
  :address_line,
  :city,
  :code,
  :country,
  :date_of_birth,
  :description,
  :details,
  :email,
  :first_name,
  :hearing_court_name,
  :hearing_date,
  :last_name,
  :lookup_id,
  :nino,
  :other_names,
  :phone,
  :postcode,
  :reason,
  :urn
]
