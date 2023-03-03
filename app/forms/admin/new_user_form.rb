module Admin
  class NewUserForm
    include ActiveModel::Model

    attr_accessor :email, :can_manage_others

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :can_manage_others, presence: false

    def save
      return unless valid?

      user = User.new(email:, can_manage_others:)
      user.save
    end
  end
end
