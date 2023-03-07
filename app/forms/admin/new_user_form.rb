module Admin
  class NewUserForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :email, :string
    attribute :can_manage_others, :boolean

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :can_manage_others, presence: false, inclusion: [true, nil]

    def save
      return unless valid?

      # TODO: look at getting boolean from form directly
      # seems to be issue with DFE form builder
      boolean_can_manage_others = can_manage_others ? true : false

      user = User.new(
        email: email,
        can_manage_others: boolean_can_manage_others
      )

      user.save
    end
  end
end
