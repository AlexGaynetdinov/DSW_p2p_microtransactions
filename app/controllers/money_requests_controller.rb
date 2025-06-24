class MoneyRequestsController < ApplicationController
  def create
    recipient = User.find_by(id: money_request_params[:recipient_id])
    amount = money_request_params[:amount].to_f

    if recipient.nil?
      return render json: { error: "Recipient not found" }, status: :not_found
    end

    request = MoneyRequest.new(
      requester: current_user,
      recipient: recipient,
      amount: amount,
      message: money_request_params[:message],
      status: 'pending'
    )

    if request.save
      render json: request, status: :created
    else
      render json: { errors: request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    requests = MoneyRequest.where(recipient: current_user).order(created_at: :desc)
    render json: requests
  end

  def sent
    requests = MoneyRequest.where(requester: current_user).order(created_at: :desc)
    render json: requests
  end

  def accept
    request = MoneyRequest.find_by(id: params[:id], recipient: current_user, status: 'pending')

    unless request
      return render json: { error: "Request not found or already handled" }, status: :not_found
    end

    if current_user.balance < request.amount
      return render json: { error: "Insufficient funds to fulfill request" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      current_user.update!(balance: current_user.balance - request.amount)
      request.requester.update!(balance: request.requester.balance + request.amount)

      Transaction.create!(
        sender: current_user,
        recipient: request.requester,
        amount: request.amount,
        message: request.message || "Money request accepted"
      )

      request.update!(status: 'accepted')
      render json: { message: "Request accepted and money sent" }, status: :ok
    end
  end

  def reject
    request = MoneyRequest.find_by(id: params[:id], recipient: current_user, status: 'pending')

    unless request
      return render json: { error: "Request not found or already handled" }, status: :not_found
    end

    request.update!(status: 'rejected')
    render json: { message: "Request rejected" }, status: :ok
  end

  private

  def money_request_params
    params.permit(:recipient_id, :amount, :message)
  end
end
