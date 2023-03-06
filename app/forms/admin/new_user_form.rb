module Admin
  class NewUserForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :email, :string
    attribute :can_manage_others, :boolean

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :can_manage_others, presence: false

    def save
      return unless valid?

      user = User.new(email:, can_manage_others:)
      user.save
    end
  end
end
