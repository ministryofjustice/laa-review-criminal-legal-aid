class Review < ApplicationRecord
  #
  # Review is a CQRS read model. It is configured by the
  # Reviews::Configuration class
  #
  def readonly?
    true
  end
end
