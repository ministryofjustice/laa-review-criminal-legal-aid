module Reportable
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def _report_name
      name.demodulize.underscore
    end
  end

  def report_name
    self.class._report_name
  end

  def id
    report_name
  end
end
