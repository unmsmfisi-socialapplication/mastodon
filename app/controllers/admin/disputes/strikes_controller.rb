# frozen_string_literal: true

class Admin::Disputes::StrikesController < Admin::BaseController
  before_action :set_strike, only: [:show]

  def show
    authorize @strike, :show?
    @appeal = @strike.appeal
    @appeal_note = @appeal.notes.new
    @appeal_notes = @appeal.notes.chronological.includes(:account)
  end

  private

  def set_strike
    @strike = AccountWarning.find(params[:id])
  end
end
