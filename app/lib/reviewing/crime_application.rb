class Reviewing::CrimeApplication
  include AggregateRoot

  def initialize(id)
    @id = id
    @state = :submitted
  end

  attr_reader :id

  # Send Back then unnassign
  def send_back_to_provider(user_id)
    Reviewing::SendBackToProvider.new(
    ).call
  end
end
