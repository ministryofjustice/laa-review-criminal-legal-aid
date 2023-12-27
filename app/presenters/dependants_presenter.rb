class DependantsPresenter < BasePresenter
  def initialize(dependants)
    super(
      @dependants = dependants
    )
  end

  def formatted_dependants
    return unless @dependants

    dependants_by_age_range
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def dependants_by_age_range
    sorted_dependants = Hash.new(0)

    @dependants.each do |dependant|
      case dependant[:age]
      when 0, 1
        sorted_dependants['0 to 1'] += 1
      when 2, 3, 4
        sorted_dependants['2 to 4'] += 1
      when 5, 6, 7
        sorted_dependants['5 to 7'] += 1
      when 8, 9, 10
        sorted_dependants['8 to 10'] += 1
      when 11, 12
        sorted_dependants['11 to 12'] += 1
      when 13, 14, 15
        sorted_dependants['13 to 15'] += 1
      else
        sorted_dependants['16 to 18'] += 1
      end
    end

    sorted_dependants
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
end
