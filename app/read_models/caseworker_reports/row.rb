module CaseworkerReports
  class Row
    COUNTERS = %w[
      assigned_to_user
      reassigned_to_user
      reassigned_from_user
      unassigned_from_user
      completed_by_user
      sent_back_by_user
    ].freeze

    def initialize(user_id)
      @user_id = user_id

      COUNTERS.each do |counter|
        instance_variable_set(:"@#{counter}", 0)
      end
    end

    attr_reader :user_id, *COUNTERS

    def user_name
      User.name_for(@user_id)
    end

    def total_assigned_to_user
      assigned_to_user + reassigned_to_user
    end

    def total_unassigned_from_user
      reassigned_from_user + unassigned_from_user
    end

    def total_closed_by_user
      completed_by_user + sent_back_by_user
    end

    def percentage_unassigned_from_user
      return 0 if total_assigned_to_user.zero?

      (Rational(total_unassigned_from_user, total_assigned_to_user) * 100).round
    end

    def percentage_closed_by_user
      return 0 if total_assigned_to_user.zero?

      (Rational(total_closed_by_user, total_assigned_to_user) * 100).round
    end

    def percentage_closed_sent_back
      return 0 if total_closed_by_user.zero?

      (Rational(sent_back_by_user, total_closed_by_user) * 100).round
    end

    def assign
      @assigned_to_user += 1
    end

    def reassign_to
      @reassigned_to_user += 1
    end

    def reassign_from
      @reassigned_from_user += 1
    end

    def unassign
      @unassigned_from_user += 1
    end

    def send_back
      @sent_back_by_user += 1
    end

    def complete
      @completed_by_user += 1
    end
  end
end
