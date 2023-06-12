# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :_key, :certificate, :client_id, :client_secret,
  :oid, :otp, :passw, :pkce, :salt, :secret, :ssn,
  :tenant_id, :token,

  # Attributes relating to an application
  # It does partial matching (i.e. `telephone_number` is covered by `phone`)
  :address,
  :address_line_one,
  :address_line_two,
  :application_start_date,
  :city,
  :code,
  :country,
  :crypt,
  :date_of_birth,
  :details,
  :description,
  :email,
  :first_name,
  :hearing_court_name,
  :hearing_date,
  :last_name,
  :lookup_id,
  :name,
  :nino,
  :other_names,
  :phone,
  :postcode,
  :reason,
  :submission_date,
  :urn
]
