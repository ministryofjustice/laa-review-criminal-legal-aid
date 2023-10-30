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

  # Creates an array of table headers for each column name given.
  #
  # If the column is sortable, (exists in Types::SORTABLE_COLUMNS), then a
  # form for sorting by that column is used for the table header.
  #
  # The sortable column form includes params from any base_params provided.
  #
  def table_headers(column_names, search:, base_params: {}, sort_form_method: :get)
    base_params[:per_page] = search.pagination.limit_value

    headers = column_names.map do |column_name|
      TableHeader.new(column_name:, search:)
    end

    render headers, base_params:, sort_form_method:
  end

  # Rails link_to_if and variants still render the link text hence custom implementation
  # https://govuk-components.netlify.app/helpers/link/#input-erb-class-helpers
  def gov_link_to_unless_current_user(user:, **options)
    return '' if current_user == user

    govuk_link_to options[:text], options[:path], options[:html_options]
  end

  def decorate(model, decorator_class = nil)
    (decorator_class || [model.class, :Decorator].join.demodulize.constantize).new(model)
  end

  def present(model, presenter_class = nil)
    (presenter_class || [model.class, :Presenter].join.demodulize.constantize).new(model)
  end
end
