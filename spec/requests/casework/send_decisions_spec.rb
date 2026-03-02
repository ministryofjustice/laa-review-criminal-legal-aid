require 'rails_helper'

RSpec.describe 'Sending application decisions' do
  include Devise::Test::IntegrationHelpers

  include_context 'with an existing user'
  include_context 'with stubbed application'

  before do
    sign_in user
  end

  describe 'Errors' do
    describe 'create' do
      let(:create) do
        post "/applications/#{application_id}/what-do-you-want-to-do-next",
             params: { decisions_send_to_provider_form: { next_step: 'send_to_provider' } }
      end

      describe 'UnexpectedAssignee' do
        before do
          decision_id = SecureRandom.uuid
          another_user_id = SecureRandom.uuid

          Assigning::AssignToUser.new(assignment_id: application_id, user_id: user.id,
                                      to_whom_id: user.id, reference: 1_234_567).call
          Reviewing::AddDecision.new(application_id: application_id, user_id: user.id,
                                     decision_id: decision_id).call
          Deciding::CreateDraft.new(application_id: application_id, user_id: user.id, reference: 1_234_567,
                                    decision_id: decision_id).call
          Deciding::SetFundingDecision.new(decision_id: decision_id, user_id: user.id, funding_decision: 'refused').call
          Assigning::ReassignToUser.new(assignment_id: application_id, user_id: another_user_id,
                                        to_whom_id: another_user_id, from_whom_id: user.id, reference: 1_234_567).call

          create
        end

        it 'sets the correct flash message and redirects' do
          expect(flash[:important]).to eq(['This application is assigned to someone else',
                                           'Ask your supervisor if you need to work on it.'])
          expect(response).to redirect_to("/applications/#{application_id}")
        end
      end
    end
  end
end
