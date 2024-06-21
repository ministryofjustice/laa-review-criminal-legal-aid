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
  # NOTE: Output is to show grouping by NEXT birthday age,
  # not their current (user entered) age
  def dependants_by_age_range
    grouped_dependants = Hash.new(0)

    sorted_dependants.each do |dependant|
      case dependant[:age]
      when 0
        grouped_dependants['0 to 1'] += 1
      when 1, 2, 3
        grouped_dependants['2 to 4'] += 1
      when 4, 5, 6
        grouped_dependants['5 to 7'] += 1
      when 7, 8, 9
        grouped_dependants['8 to 10'] += 1
      when 10, 11
        grouped_dependants['11 to 12'] += 1
      when 12, 13, 14
        grouped_dependants['13 to 15'] += 1
      when 15, 16, 17
        grouped_dependants['16 to 18'] += 1
      end
    end

    grouped_dependants
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  def sorted_dependants
    # Sorts ages so the ranking is ordered
    @dependants.sort_by { |d| d[:age] }
  end
end
