class WorkStream
  include ActiveModel::Model
  PARAM_MAP = { criminal_applications_team: 'cat_1',
                  national_crime_team: 'cat_2',
                  extradition: 'extradition'
  }.with_indifferent_access.freeze

  def initialize(work_stream)
    @work_stream = work_stream
  end

  def to_s
    @work_stream
  end

  def ==(other)
    other.to_s == @work_stream.to_s
  end

  def to_param
    PARAM_MAP.fetch(@work_stream.to_sym)
  end

  class << self
    def from_param(param)
      new(PARAM_MAP.key(param))
    end
  end
end
