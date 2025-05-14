class RoleChangedNotifier
  def call(event)
    Rails.error.handle do
      admin_emails = User.admins.map(&:email)
      user = User.find(event.data.fetch(:user_id))

      NotifyMailer.role_changed_email(admin_emails, user).deliver_later
    end
  end
end
