# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Disputes::AppealNotesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:account) { user.account }
  let(:appeal) { Fabricate(:appeal) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    subject { post :create, params: params }


    context 'when parameters are valid' do
      let(:params) { { appeal_note: { appeal_id: appeal.id, content: 'Valid content' } } }

      it 'creates an appeal note' do
        expect { subject }.to change(AppealNote, :count).by(1)
        expect(response).to redirect_to admin_disputes_strike_path(appeal.strike)
        expect(flash[:notice]).to eq(I18n.t('admin.disputes.appeal_notes.created_msg'))
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { appeal_note: { appeal_id: appeal.id, content: '' } } }

      it 'renders the strike show view' do
        expect { subject }.to_not change(AppealNote, :count)
        expect(response).to render_template 'admin/disputes/strikes/show'
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: appeal_note.id } }

    let!(:appeal_note) { Fabricate(:appeal_note, appeal: appeal) }

    it 'deletes the appeal note' do
      expect { subject }.to change(AppealNote, :count).by(-1)
      expect(response).to redirect_to admin_disputes_strike_path(appeal.id)
      expect(flash[:notice]).to eq(I18n.t('admin.disputes.appeal_notes.destroyed_msg'))
    end
  end
end