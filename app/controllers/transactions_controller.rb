class TransactionsController < ApplicationController
  def create
    recipient = User.find_by(id: transaction_params[:recipient_id])
    amount = transaction_params[:amount].to_f

    if recipient.nil?
      return render json: { error: "Recipient not found" }, status: :not_found
    end

    if current_user.balance < amount
      return render json: { error: "Insufficient funds" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      current_user.update!(balance: current_user.balance - amount)
      recipient.update!(balance: recipient.balance + amount)
      tx = Transaction.create!(
        sender: current_user,
        recipient: recipient,
        amount: amount,
        message: transaction_params[:message]
      )

      render json: {
        message: "Transaction successful",
        transaction: tx
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def index
    transactions = Transaction.where(sender: current_user).or(Transaction.where(recipient: current_user)).order(created_at: :desc)
    render json: transactions
  end

  private

  def transaction_params
    params.permit(:recipient_id, :amount, :message)
  end
end
