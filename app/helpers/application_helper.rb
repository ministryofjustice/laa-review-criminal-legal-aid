module ApplicationHelper
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
    (controller_name == 'crime_applications' && %w[open closed].include?(action_name)) ||
      (controller_name == 'application_searches' && %w[search new].include?(action_name)) ||
      (controller_name == 'assigned_applications' && %w[index].include?(action_name))
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
end
