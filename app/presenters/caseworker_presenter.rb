class CaseworkerPresenter < BasePresenter
  def formatted_user_competencies
    if Allocating.user_competencies(id).present?
      competencies = Allocating.user_competencies(id).map { |c| t(c, scope: 'labels') }
      competencies.join(', ')
    else
      I18n.t('manage_competencies.caseworker_competencies.table_cells.no_competencies')
    end
  end

  def format_percentage(value)
    value.nil? ? nil : "#{value}%"
  end
end
