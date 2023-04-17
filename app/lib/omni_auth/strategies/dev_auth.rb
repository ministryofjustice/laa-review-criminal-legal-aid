module OmniAuth
  module Strategies
    class DevAuth
      # IMPORTANT NOTE: This OmniAuth strategy is intended for local
      # development purposes only.
      #
      # During the callback phase, this strategy searches for a user
      # with the given email address in the local database. If a user
      # with a matching email address is found and is authorised,
      # the strategy constructs an auth hash based on the user's
      # information in the database.
      #
      # In cases where the strategy is unable to find an authorised
      # user with the given email address, it sets an auth_subject_id
      # and guesses the user's first and last name based on the email
      # address.

      include OmniAuth::Strategy

      NO_AUTH_EMAIL = 'Not.Authorised@example.com'.freeze

      uid { auth_subject_id }
      credentials { { expires_in: 12.hours } }
      info { { email:, first_name:, last_name: } }

      # Redirect to the dev_auth form, so that a user can be selected.
      def request_phase
        redirect('/dev_auth')
      end

      private

      def email
        @email ||= request.params.fetch('email')
      end

      def user
        @user ||= User.find_by(email:)
      end

      def auth_subject_id
        user&.auth_subject_id || SecureRandom.uuid
      end

      def first_name
        user&.first_name || names_from_email.first
      end

      def last_name
        user&.last_name || names_from_email.last
      end

      def names_from_email
        @names_from_email ||= email.split('@').first.split('.')
      end
    end
  end
end
