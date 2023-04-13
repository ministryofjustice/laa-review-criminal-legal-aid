module OmniAuth
  module Strategies
    class DevAuth
      # IMPORTANT NOTE: This OmniAuth strategy is intended for local
      # development purposes only.
      #
      # When a user clicks the "Sign in" button with this strategy,
      # they are directed to the DevAuth form where they can select
      # the email of an existing user to log in as. To add an admin
      # user, run "bundle exec rails db:seed" if it has not been
      # done already.
      #
      # The list of user emails includes a Non Authorised user's
      # email (NO_AUTH_EMAIL), which developers can use to simulate
      # a non-authorised authenticated user.
      #
      # During the callback phase, this strategy searches for a user
      # with the given email address in the local database. If a user
      # with a matching email address is found and is authenticated,
      # the strategy constructs an auth hash based on the user's
      # information in the database.
      #
      # In cases where the strategy is unable to find an authenticated
      # user with the given email address, it sets an auth_subject_id
      # and guesses the user's first and last name based on the email
      # address.

      include OmniAuth::Strategy

      NO_AUTH_EMAIL = 'Not.Authorised@example.com'.freeze

      uid { auth_subject_id }
      credentials { { expires_in: 12.hours } }
      info { { email:, first_name:, last_name: } }

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
