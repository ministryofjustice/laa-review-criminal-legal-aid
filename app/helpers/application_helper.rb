module ApplicationHelper
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

  def app_banner_tag
    if HostEnv.local?
      t('phase_banner.tag.local')
    elsif HostEnv.staging?
      t('phase_banner.tag.staging')
    else
      t('phase_banner.tag.production')
    end
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
    raise exception if Rails.application.config.consider_all_requests_local

    title ''
  end

  # Rails link_to_if and variants still render the link text hence custom implementation
  # https://govuk-components.netlify.app/helpers/link/#input-erb-class-helpers
  def gov_link_to_unless_current_user(user:, **options)
    return '' if current_user == user

    govuk_link_to options[:text], options[:path], options[:html_options]
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

  def closed_action?(action_name)
    action_name == 'closed'
  end
end
