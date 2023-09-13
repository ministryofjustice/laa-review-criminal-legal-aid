module Reporting
  module Reportable
    extend ActiveSupport::Concern

    def rows
      @rows ||= Reporting.const_get(report_type.camelize).new(stream_name:).rows
    end

    private

    def report_text(key, options = {})
      I18n.t(key, scope: i18n_scope, **options)
    end

    def i18n_scope
      self.class.name.underscore.split('/') << report_type
    end
  end
end
