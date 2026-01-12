require 'rails_helper'

RSpec.describe 'Returning applications' do
  include Devise::Test::IntegrationHelpers

  include_context 'with an existing user'
  include_context 'with stubbed application'

  before do
    sign_in user
  end

  describe 'Errors' do
    describe 'new' do
      let(:new) { get "/applications/#{application_id}/return/new" }

      before do
        another_user_id = SecureRandom.uuid
        Assigning::AssignToUser.new(assignment_id: application_id, user_id: another_user_id,
                                    to_whom_id: another_user_id).call

        new
      end

      it 'sets the correct flash message and redirects' do
        expect(flash[:important]).to eq(['You cannot review this application',
                                         'It has been reassigned to another team member.',
                                         'Contact your supervisor if you need to work on this application.'])
        expect(response).to redirect_to("/applications/#{application_id}")
      end
    end

    describe 'create' do
      let(:return_details) { { reason: 'clarification_required', details: 'clarify' } }
      let(:create) do
        post "/applications/#{application_id}/return",
             params: { return_details: }
      end

      before do
        allow(DatastoreApi::Requests::UpdateApplication).to receive(:new)
          .and_return(instance_double(DatastoreApi::Requests::UpdateApplication, call: {}))
      end

      describe 'AlreadyReviewed' do
        before do
          Assigning::AssignToUser.new(assignment_id: application_id, user_id: user.id,
                                      to_whom_id: user.id).call
          Reviewing::SendBack.new(application_id: application_id, user_id: user.id,
                                  return_details: return_details).call

          create
        end

        it 'sets the correct flash message and redirects' do
          expect(flash[:important]).to eq('This application was already reviewed')
          expect(response).to redirect_to("/applications/#{application_id}")
        end
      end

      describe 'UnexpectedAssignee' do
        before do
          another_user_id = SecureRandom.uuid
          Assigning::AssignToUser.new(assignment_id: application_id, user_id: user.id,
                                      to_whom_id: user.id).call
          Assigning::ReassignToUser.new(assignment_id: application_id, user_id: another_user_id,
                                        to_whom_id: another_user_id, from_whom_id: user.id).call

          create
        end

        it 'sets the correct flash message and redirects' do
          expect(flash[:important]).to eq(['You cannot review this application',
                                           'It has been reassigned to another team member.',
                                           'Contact your supervisor if you need to work on this application.'])
          expect(response).to redirect_to("/applications/#{application_id}")
        end
      end
    end
  end
end
