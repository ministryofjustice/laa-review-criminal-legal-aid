class User < ApplicationStruct
  attribute :id, Types::String
  attribute :first_name, Types::String
  attribute :last_name, Types::String
  attribute :email, Types::String
  attribute :roles, Types::Array.of(Types::UserRole)

  def name
    [first_name, last_name].join(' ')
  end

  # TODO: Temporary in lieu of data api decision.
  def assigned_applications
    CrimeApplication.all.select do |app|
      app.current_assignment.assigned_to_user? self
    end
  end
end
