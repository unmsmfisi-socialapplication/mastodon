# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Disputes::StrikesController do
  render_views

  let(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:account) { Fabricate(:account) }
  let(:appeal) { Fabricate(:appeal, account: account) }
  let(:strike) { Fabricate(:account_warning, appeal: appeal) }

  before do
    sign_in admin, scope: :user
  end

  describe 'GET #show' do
    subject { get :show, params: { id: strike.id } }

    describe 'when accessed by an admin' do
      it 'returns http success' do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'assigns the correct strike and related variables' do
        subject
        expect(assigns(:strike)).to eq(strike)
        expect(assigns(:appeal)).to eq(appeal)
        expect(assigns(:appeal_note)).to be_a_new(AppealNote)
        expect(assigns(:appeal_notes)).to eq(appeal.notes.chronological.includes(:account))
      end
    end
  end
end