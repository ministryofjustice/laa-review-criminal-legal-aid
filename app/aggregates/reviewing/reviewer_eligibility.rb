module Reviewing
  class ReviewerEligibility
    attr_reader :user, :review

    def initialize(user:, review:)
      @user = user
      @review = review
    end

    def allowed?
      user.caseworker? || user.supervisor?
    end
  end
end
