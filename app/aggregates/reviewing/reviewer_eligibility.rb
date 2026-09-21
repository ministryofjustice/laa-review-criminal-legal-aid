module Reviewing
  class ReviewerEligibility
    attr_reader :user, :review

    def initialize(user:, review:)
      @user = user
      @review = review
    end

    def allowed?
      user.caseworker? || user.supervisor? || user.business_support?
    end
  end
end
