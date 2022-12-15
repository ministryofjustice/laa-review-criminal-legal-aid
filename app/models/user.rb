class User < ApplicationRecord
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
