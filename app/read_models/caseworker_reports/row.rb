module CaseworkerReports
  class Row
    COUNTERS = %w[
      assigned_to_user
      reassigned_to_user
      reassigned_from_user
      completed_by_user
      sent_back_by_user
    ].freeze

    def initialize(user_id, work_queue = nil)
      @user_id = user_id
      @work_queue = work_queue
      @unassigned_from_user_ids = []

      COUNTERS.each do |counter|
        instance_variable_set(:"@#{counter}", 0)
      end
    end

    attr_reader :user_id, :work_queue, :unassigned_from_user_ids, *COUNTERS

    def user_name
      User.name_for(@user_id)
    end

    # plan so far:
    # add ids for assigned and unassigned etc to the data
    # store in the generated reports
    # link to the period for the caseworker
    # caseworker controller will use user id to key the caseworker report and get the attribute required
    #
    # alternative is to create a new linked stream for each caseworker
    # this can then be used to build an individual report.

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
      return nil if total_assigned_to_user.zero?

      (Rational(total_unassigned_from_user, total_assigned_to_user) * 100).round
    end

    def percentage_closed_by_user
      return nil if total_assigned_to_user.zero?

      (Rational(total_closed_by_user, total_assigned_to_user) * 100).round
    end

    def percentage_closed_sent_back
      return nil if total_closed_by_user.zero?

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

    def unassign(assignment_id)
      @unassigned_from_user_ids << assignment_id
    end

    def unassigned_from_user
      @unassigned_from_user_ids.size
    end

    def unassigned_ids
      @unassigned_ids += 1
    end

    def send_back
      @sent_back_by_user += 1
    end

    def complete
      @completed_by_user += 1
    end
  end
end
