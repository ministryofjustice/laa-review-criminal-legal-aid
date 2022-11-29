class ApplicationSearch < ApplicationStruct
  attribute :filter, Types.Instance(ApplicationSearchFilter)

  def applications
    return @applications if @applications

    applications = CrimeApplication.all

    if filter.assigned_user_id.present?
      applications = applications.select do |app|
        app.current_assignment.user_id == filter.assigned_user_id
      end
    end

    @applications = applications
  end

  def total
    @total ||= @applications.count
  end
end
