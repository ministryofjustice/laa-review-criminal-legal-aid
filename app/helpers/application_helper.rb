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

  def business_hours_start
    format_business_hour(Rails.configuration.x.business_hours.start)
  end

  def business_hours_end
    format_business_hour(Rails.configuration.x.business_hours.end)
  end

  private

  def format_business_hour(time_str)
    Time.find_zone('London').parse(time_str).strftime('%-l:%M%P').sub(':00', '')
  end
end
