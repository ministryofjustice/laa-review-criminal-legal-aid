class CaseworkerPresenter < BasePresenter
  CASEWORKER_COMPETENCIES = Types::CASEWORKER_COMPETENCY_TYPES

  def formatted_user_competencies
    if Allocating.user_competencies(id).present?
      Allocating.user_competencies(id).map(&:humanize).join(', ')
    else
      I18n.t('manage_competencies.caseworker_competencies.table_cells.no_competencies')
    end
  end
end