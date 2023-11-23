require 'rails_helper'

describe Utils::CurrentWorkStreamCalculator do
  subject(:calculator) { described_class.new(work_stream_param:, session_work_stream:, user_competencies:) }

  let(:work_stream_param) { 'criminal_applications_team' }
  let(:session_work_stream) { nil }
  let(:user_competencies) { nil }

  describe 'Current work stream calculation' do
    context 'when work stream param is set' do
      it 'returns a criminal applications team work stream value' do
        expect(calculator.current_work_stream).to eq Types::WorkStreamType['criminal_applications_team']
      end
    end

    context 'when work stream session is set' do
      let(:work_stream_param) { nil }
      let(:session_work_stream) { 'extradition' }

      it 'returns an extradition work stream value' do
        expect(calculator.current_work_stream).to eq Types::WorkStreamType['extradition']
      end
    end

    context 'when user competencies is set' do
      let(:work_stream_param) { nil }
      let(:user_competencies) { %w[criminal_applications_team extradition] }

      it 'returns a criminal applications team work stream value' do
        expect(calculator.current_work_stream).to eq Types::WorkStreamType['criminal_applications_team']
      end
    end

    context 'when user competencies is empty array' do
      let(:work_stream_param) { nil }
      let(:user_competencies) { [] }

      it 'returns an extradition work stream value (default)' do
        expect(calculator.current_work_stream).to eq Types::WorkStreamType['extradition']
      end
    end

    context 'when there is no param/session/competency data' do
      let(:work_stream_param) { nil }

      it 'returns an extradition work stream value (default)' do
        expect(calculator.current_work_stream).to eq Types::WorkStreamType['extradition']
      end
    end

    context 'with invalid work stream param' do
      let(:work_stream_param) { 'test' }

      it 'raises Allocating::WorkStreamNotFound' do
        expect { calculator.current_work_stream }.to raise_error Allocating::WorkStreamNotFound
      end
    end
  end
end
