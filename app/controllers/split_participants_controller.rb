class SplitParticipantsController < ApplicationController
  before_action :set_participation, only: [:accept, :reject]

  def index
    participations = current_user.split_participations.includes(:split_transaction).order(created_at: :desc)

    render json: participations.map { |p|
      {
        id: p.id,
        status: p.status,
        share: p.share,
        split_transaction_id: p.split_transaction.id,
        message: p.split_transaction.message,
        total_amount: p.split_transaction.amount,
        creator_email: p.split_transaction.creator.email,
        created_at: p.created_at
      }
    }
  end

  def accept
    if @participation.status != 'pending'
      return render json: { error: "Already handled" }, status: :unprocessable_entity
    end

    if current_user.balance < @participation.share
      return render json: { error: "Insufficient funds" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      current_user.update!(balance: current_user.balance - @participation.share)
      @participation.split_transaction.creator.update!(
        balance: @participation.split_transaction.creator.balance + @participation.share
      )

      Transaction.create!(
        sender: current_user,
        recipient: @participation.split_transaction.creator,
        amount: @participation.share,
        message: "Split: #{@participation.split_transaction.message || 'shared expense'}"
      )

      @participation.update!(status: 'accepted')

      render json: { message: "Split accepted and share paid." }, status: :ok
    end
  end

  def reject
    if @participation.status != 'pending'
      return render json: { error: "Already handled" }, status: :unprocessable_entity
    end

    @participation.update!(status: 'rejected')
    render json: { message: "Split rejected." }, status: :ok
  end

  private

  def set_participation
    @participation = SplitParticipant.find_by(id: params[:id], user: current_user)
    return render json: { error: "Not authorized" }, status: :not_found unless @participation
  end
end
