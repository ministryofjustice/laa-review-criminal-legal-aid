RSpec.shared_context 'with many other users', shared_context: :metadata do
  def make_users(num)
    users = (1..num).map do |i|
      { first_name: "Sue#{i}", last_name: "Ace#{i}", email: "sue+#{i}@example.com", auth_subject_id: SecureRandom.uuid }
    end
    User.insert_all(users) # rubocop:disable Rails/SkipsModelValidations
  end
end
