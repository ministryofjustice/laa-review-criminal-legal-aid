require 'rails_helper'

RSpec.describe Casework::BaseController, type: :controller do
  controller(described_class) do
    def index
      raise Reviewing::NotAuthorisedToReview
    end
  end

  let(:data_analyst_user) do
    User.create!(
      first_name: 'Data',
      last_name: 'Analyst',
      email: "data-analyst-#{SecureRandom.hex(4)}@example.com",
      auth_subject_id: SecureRandom.uuid,
      can_manage_others: false,
      role: UserRole::DATA_ANALYST
    )
  end

  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: data_analyst_user,
                                          current_user_id: data_analyst_user.id)
  end

  describe 'GET #index' do
    it 'sets the flash message and redirects to assigned applications when no crime application is loaded' do
      get :index

      expect(flash[:important]).to eq(['You must be a caseworker or supervisor to review an application'])
      expect(response).to redirect_to(assigned_applications_path)
    end
  end
end
