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
      app.current_assignment.user_id == value
    when :start_on
      app.submission_date >= value.beginning_of_day
    when :end_on
      app.submission_date.to_date <= value.end_of_day
    end
  end
end
