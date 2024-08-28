require 'rails_helper'

# rubocop:disable RSpec/SpecFilePathFormat

RSpec.describe ApplicationController do
  controller do
    include WorkStreamable
    before_action :set_current_work_stream

    def index
      render plain: current_work_stream
    end
  end

  describe 'GET #index' do
    subject(:request) { get :index, params: }

    let(:params) { {} }
    let(:user) { instance_double(User, work_streams: user_work_streams) }
    let(:user_work_streams) { WorkStream.all }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when a work_stream param is present' do
      let(:params) { { work_stream: 'cat_2' } }

      context 'when the user has the requested work stream as a competency' do
        it 'sets current_work_stream to be that of the param' do
          request
          expect(response.body).to eq 'criminal_applications_team_2'
        end
      end

      context 'when the user does not have requested work stream as a competency' do
        let(:user_work_streams) { [WorkStream.new('criminal_applications_team')] }

        it 'raises an Allocating::WorkStreamNotFound' do
          expect { request }.to raise_error Allocating::WorkStreamNotFound
        end
      end
    end

    context 'when neither work_stream_param nor session param is present' do
      it 'sets current_work_stream to the users first work stream' do
        request
        expect(response.body).to eq user_work_streams.first.to_s
      end
    end

    context 'when the current work_stream is set in the session' do
      before do
        session[:current_work_stream] = 'extradition'
      end

      context 'when the user has the session work_stream as a competency' do
        it 'sets current_work_stream to the session work stream' do
          request
          expect(response.body).to eq 'extradition'
        end
      end

      context 'when the user does not have the session work stream as a competency' do
        let(:user_work_streams) { [WorkStream.new('criminal_applications_team')] }

        it 'sets current_work_stream to the users first work stream' do
          request
          expect(response.body).to eq 'criminal_applications_team'
        end
      end

      context 'when the user does not have any competencies' do
        let(:user_work_streams) { [] }

        it 'raises an Allocating::WorkStreamNotFound' do
          expect { request }.to raise_error Allocating::WorkStreamNotFound
        end
      end
    end
  end
end

# rubocop:enable RSpec/SpecFilePathFormat
