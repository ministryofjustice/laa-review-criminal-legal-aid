# TODO: move

class User < ApplicationRecord
  has_many :current_assignments, class_name: 'Assignments::CurrentAssignment', dependent: :destroy

  def name
    [first_name, last_name].join(' ')
  end

  class << self
    # For GDPR caseworker personal data is not stored in the event stream.
    # Rendering an applications history can require many user names to be
    # found. This method caches those lookups.
    def name_for(id)
      Rails.cache.fetch("user_names#{id}", expires_in: 10.minutes) do
        User.find(id).name
      end
    end
  end
end
