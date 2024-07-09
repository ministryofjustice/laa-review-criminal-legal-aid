class WorkStream
  include ActiveModel::Model

  attr_reader :work_stream

  PARAM_MAP = {
    'criminal_applications_team' => 'cat_1',
    'criminal_applications_team_2' => 'cat_2',
    'extradition' => 'extradition',
    'non_means_tested' => 'non_means'
  }.freeze

  def initialize(work_stream)
    @work_stream = Types::WorkStreamType[work_stream]

    freeze
  end

  def to_s
    work_stream
  end
  alias serialize to_s

  def ==(other)
    other.to_s == @work_stream
  end
  alias eql? ==

  def to_param
    PARAM_MAP.fetch(@work_stream)
  end

  def label
    I18n.t(to_s, scope: :labels)
  end

  class << self
    def from_param(param)
      new(PARAM_MAP.key(param))
    rescue StandardError
      raise Allocating::WorkStreamNotFound
    end

    def all
      Types::WorkStreamType.values.map do |work_stream|
        new work_stream
      end
    end
  end
end
