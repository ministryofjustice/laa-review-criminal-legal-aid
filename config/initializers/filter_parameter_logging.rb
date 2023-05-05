# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += %i[
  passw
  secret
  token
  _key
  crypt
  salt
  certificate
  otp
  ssn
  oid
  tenant_id
  client_id
  client_secret
  pkce
  email
  name
  first_name
  last_name
  address
  telephone_number
  date_of_birth
  address_line_one
  address_line_two
  county
  postcode
  urn
  hearing_court_name
  hearing_date
  reason
  national_insurance_number
  application_start_date
  submission_date
]
