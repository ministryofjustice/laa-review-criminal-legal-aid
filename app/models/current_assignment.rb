class CurrentAssignment < ApplicationRecord
  belongs_to :user

  def assigned_to_user?(user)
    user === user
  end

  def readonly?
    true
  end
end
