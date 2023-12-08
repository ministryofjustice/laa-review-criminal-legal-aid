class CaseworkerPresenter < BasePresenter
  CASEWORKER_COMPETENCIES = Types::CompetencyType.values

  def formatted_user_competencies
    if Allocating.user_competencies(id).present?
      competencies = Allocating.user_competencies(id).map { |c| t(c, scope: 'labels') }
      competencies.join(', ')
    else
      I18n.t('manage_competencies.caseworker_competencies.table_cells.no_competencies')
    end
  end
end
