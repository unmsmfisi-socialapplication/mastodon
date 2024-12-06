# frozen_string_literal: true

class Admin::Disputes::AppealNotesController < Admin::BaseController
  before_action :set_appeal_note, only: [:destroy]

  def create
    authorize :report_note, :create?

    @appeal_note = current_account.appeal_notes.new(resource_params)
    @appeal      = @appeal_note.appeal

    if @appeal_note.save
      redirect_to after_create_redirect_path, notice: I18n.t('admin.disputes.appeal_notes.created_msg')
    else
      @appeal_notes = @appeal.notes.chronological.includes(:account)
      @form         = Admin::StatusBatchAction.new
      
      render 'admin/disputes/strikes/show'
    end
  end

  def destroy
    authorize @appeal_note, :destroy?
    @appeal_note.destroy!
    redirect_to admin_disputes_strike_path(@appeal.strike), notice: I18n.t('admin.disputes.appeal_notes.destroyed_msg')
  end

  private

  def after_create_redirect_path
    admin_disputes_strike_path(@appeal.strike)
  end

  def resource_params
    params.require(:appeal_note).permit(
      :content,
      :appeal_id
    )
  end

  def set_appeal_note
    @appeal_note = AppealNote.find(params[:id])
  end
end