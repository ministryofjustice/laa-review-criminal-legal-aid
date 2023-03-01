class User < ApplicationRecord
  has_many :current_assignments, dependent: :destroy

  def name
    [first_name, last_name].join(' ')
  end

  class << self
    #
    # For GDPR caseworker personal data is not stored in the event stream.
    # Rendering an application's history can require many user names to be
    # found. This method caches those lookups.
    #
    # It returns "[deleted]" for a forgotten/not found user
    #
    def name_for(id)
      Rails.cache.fetch("user_names#{id}", expires_in: 10.minutes) do
        User.find(id).name
      rescue ActiveRecord::RecordNotFound
        I18n.t('values.deleted_user_name')
      end
    end

    #
    # TODO find a better home.
    #
    def authenticate!(auth_info)
      authenticate_and_update!(auth_info) || authenticate_and_activate!(auth_info)
    end

    def authenticate_and_update!(info)
      user = User.find_by(auth_oid: info.fetch('auth_oid'))

      return nil unless user

      user.update(
        first_name: info['first_name'],
        last_name: info['last_name'],
        email: info['email'],
        last_auth_at: Time.zone.now
      )

      user
    end

    def authenticate_and_activate!(info)
      user = User.find_by email: info['email'], auth_oid: nil, first_auth_at: nil

      return nil unless user

      user.update(
        auth_oid: info.fetch('auth_oid'),
        first_name: info['first_name'],
        last_name: info['last_name'],
        last_auth_at: Time.zone.now,
        first_auth_at: Time.zone.now
      )

      user
    end
  end
end
