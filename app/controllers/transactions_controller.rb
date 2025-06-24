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

  def admin_revert
    return render json: { error: 'Forbidden' }, status: :forbidden unless current_user.admin?

    original = Transaction.find_by(id: params[:id])
    unless original
      return render json: { error: 'Original transaction not found' }, status: :not_found
    end

    reversed = Transaction.create(
      sender_id: original.recipient_id,
      recipient_id: original.sender_id,
      amount: original.amount,
      message: 'Pay App - admin refund'
    )

    if reversed.persisted?
      render json: {message: 'Transaction reversed successfully', transaction: reversed}
    else
      render json: { error: reversed.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.permit(:recipient_id, :amount, :message)
  end
end
