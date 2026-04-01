require 'rails_helper'

RSpec.describe Casework::BaseController, type: :controller do
  controller(described_class) do
    def index
      raise Reviewing::NotAuthorisedToReview
    end
  end

  include_context 'with an existing supervisor user'

  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: supervisor_user,
                                          current_user_id: supervisor_user.id)
  end

  describe 'GET #index' do
    it 'sets the flash message and redirects to assigned applications when no crime application is loaded' do
      get :index

      expect(flash[:important]).to eq(['You must be a caseworker to review an application'])
      expect(response).to redirect_to(assigned_applications_path)
    end
  end
end
