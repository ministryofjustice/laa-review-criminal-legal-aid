class UserRole
  ROLES = %w[caseworker supervisor].freeze

  def initialize(role)
    @role = role
  end

  # Put rules here

  # def can_read_application?
  #   %w[caseworker supervisor].include?(@role)
  # end

  # def can_write_application?
  #   %w[supervisor].include?(@role)
  # end
end
