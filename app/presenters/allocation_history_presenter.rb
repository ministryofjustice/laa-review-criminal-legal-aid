class AllocationHistoryPresenter < BasePresenter
  def initialize(event)
    super(
      @event = event
    )
  end

  delegate :data, :timestamp, :event_type, to: :@event

  def supervisor_name
    return '--' unless supervisor_id

    User.name_for supervisor_id
  end

  def supervisor_id
    @supervisor_id ||= data.fetch(:by_whom_id, nil)
  end

  def description
    if @event.data[:competencies].empty?
      I18n.t('manage_competencies.history.show.competencies_set', competencies_text: 'no competencies')
    else
      competencies = @event.data[:competencies].map { |c| t(c, scope: 'labels') }
      I18n.t('manage_competencies.history.show.competencies_set',
             competencies_text: competencies.join(', '))
    end
  end
end
