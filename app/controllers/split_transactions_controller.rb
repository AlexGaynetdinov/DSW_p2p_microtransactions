class SplitTransactionsController < ApplicationController
  def create
    amount = split_params[:amount].to_f
    message = split_params[:message]
    participant_ids = params[:participant_ids]

    if participant_ids.blank? || amount <= 0
      return render json: { error: "Participants and amount are required" }, status: :unprocessable_entity
    end

    users = User.where(id: participant_ids)
    if users.size != participant_ids.size
      return render json: { error: "One or more users not found" }, status: :not_found
    end

    share = (amount / users.size.to_f).round(2)

    split_tx = SplitTransaction.create!(
      creator: current_user,
      amount: amount,
      message: message
    )

    users.each do |user|
      SplitParticipant.create!(
        user: user,
        split_transaction: split_tx,
        share: share,
        status: 'pending'
      )
    end

    render json: {
      message: "Split request created. Awaiting participant approval.",
      total_amount: amount,
      per_user: share,
      participants: users.map(&:email)
    }, status: :created
  end

  def index
    splits = SplitTransaction.includes(:split_participants => :user).where(creator: current_user).order(created_at: :desc)
    render json: splits.map { |split|
      {
        id: split.id,
        message: split.message,
        total_amount: split.amount,
        created_at: split.created_at,
        participants: split.split_participants.map { |p|
          {
            email: p.user.email,
            share: p.share,
            status: p.status
          }
        }
      }
    }
  end

  def all
    return render json: { error: 'Forbidden' }, status: :forbidden unless current_user.admin?

    splits = SplitTransaction.includes(:creator, split_participants: :user).order(created_at: :desc)

    render json: splits.map { |s|
      {
        id: s.id,
        message: s.message,
        total_amount: s.amount,
        created_at: s.created_at,
        creator: {
          id: s.creator.id,
          email: s.creator.email,
          name: s.creator.name
        },
        participants: s.split_participants.map { |p|
          {
            id: p.id,
            email: p.user.email,
            share: p.share,
            status: p.status
          }
        }
      }
    }
  end

  private

  def split_params
    params.permit(:amount, :message, participant_ids: [])
  end
end
