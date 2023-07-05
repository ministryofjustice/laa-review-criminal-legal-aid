class AccessGrantedNotifier
  def call(event)
    Rails.error.handle do
      email = User.find(event.data.fetch(:user_id)).email
      NotifyMailer.access_granted_email(email).deliver_now
    end
  end
end
