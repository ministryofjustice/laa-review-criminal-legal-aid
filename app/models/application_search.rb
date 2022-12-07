class ApplicationSearch < ApplicationStruct
  attribute :filter, Types.Instance(ApplicationSearchFilter)

  def initialize(attrs)
    @base_scope = attrs.delete(:scope) { CrimeApplication.all }
    super(attrs)
  end

  def applications
    return @applications if @applications
    return base_scope if filter.empty?

    @applications = base_scope.select do |app|
      satisfies_all(app)
    end
  end

  def total
    @total ||= applications.count
  end

  private

  attr_reader :base_scope

  def satisfies_all(app)
    filter.constraints.all? { |key, value| satisfied?(app, key, value) }
  end

  def satisfied?(app, key, value)
    case key
    when :assigned_user_id
      if value == CurrentAssignment::ALL_ASSIGNED_USER.id
        app.current_assignment.user_id != CurrentAssignment::UNASSIGNED_USER.id
      else
        app.current_assignment.user_id == value
      end
    when :start_on
      app.submitted_at >= value.beginning_of_day
    when :end_on
      app.submitted_at.to_date <= value.end_of_day
    when :applicant_date_of_birth
      app.applicant_date_of_birth == value
    end
  end
end
