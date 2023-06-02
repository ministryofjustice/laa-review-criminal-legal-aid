# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += %i[
  _key
  address
  address_line_one
  address_line_two
  application_start_date
  certificate
  client_id
  client_secret
  code
  country
  crypt
  date_of_birth
  email
  first_name
  hearing_court_name
  hearing_date
  last_name
  name
  nino
  oid
  other_names
  otp
  passw
  pkce
  postcode
  reason
  salt
  secret
  ssn
  submission_date
  telephone_number
  tenant_id
  token
  urn
]
