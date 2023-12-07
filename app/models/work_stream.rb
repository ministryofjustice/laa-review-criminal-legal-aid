class WorkStream
  include ActiveModel::Model

  attr_reader :work_stream

  PARAM_MAP = {
    'criminal_applications_team' => 'cat_1',
    'criminal_applications_team_2' => 'cat_2',
    'extradition' => 'extradition'
  }.freeze

  def initialize(work_stream)
    @work_stream = Types::WorkStreamType[work_stream]

    freeze
  end

  def to_s
    work_stream
  end

  def ==(other)
    other.to_s == @work_stream
  end

  def to_param
    PARAM_MAP.fetch(@work_stream)
  end

  class << self
    def from_param(param)
      new(PARAM_MAP.key(param))
    rescue StandardError
      raise Allocating::WorkStreamNotFound
    end
  end
end
