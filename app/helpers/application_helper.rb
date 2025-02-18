module ApplicationHelper
  include GOVUKDesignSystemFormBuilder::BuilderHelper
  include CaseworkHelper

  # Convert to the London time zone before localizing.
  def tz_l(timestamp, options = {})
    return if timestamp.nil?

    time_zone = options.fetch(:time_zone, 'London')

    I18n.l(timestamp.in_time_zone(time_zone), **options)
  end

  alias l tz_l

  def service_name
    t('service.name')
  end

  def top_level_path?
    top_level_paths = [
      assigned_applications_path,
      open_crime_applications_path,
      closed_crime_applications_path,
      search_application_searches_path,
      new_application_searches_path
    ]

    top_level_paths.include?(request.path)
  end

  def title(page_title)
    content_for(
      :page_title, [page_title.presence, service_name, 'GOV.UK'].compact.join(' - ')
    )
  end

  # In local/test we raise an exception, so we are aware a title has not been set
  def fallback_title
    exception = StandardError.new("page title missing: #{controller_name}##{action_name}")
    raise exception if Rails.env.local?

    title ''
  end

  def present(model, presenter_class = nil)
    (presenter_class || [model.class, :Presenter].join.demodulize.constantize).new(model)
  end

  def search_by_caseworker_path(user_id)
    filter = { assigned_status: user_id, application_status: 'open' }
    search_application_searches_path(filter:)
  end

  def link_to_search_by_caseworker(user_name, user_id)
    govuk_link_to(
      user_name,
      search_by_caseworker_path(user_id),
      data: { turbo: false },
      no_visited_state: true
    )
  end

  def no_data(colname)
    column_name = t(colname, scope: 'table_headings')

    govuk_visually_hidden(value_text(:no_data_for, column_name:))
  end

  def closed_action?(action_name)
    action_name == 'closed'
  end

  def subject_t(conjunction = 'and')
    if partner_subject?
      I18n.t('helpers.subjects.applicant_and_partner', conjunction:)
    else
      I18n.t('helpers.subjects.applicant')
    end
  end

  def partner_included_in_means?
    return false if current_crime_application.partner.blank?

    current_crime_application.partner.is_included_in_means_assessment
  end

  alias partner_subject? partner_included_in_means?
end
