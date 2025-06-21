class PosPaymentsController < ApplicationController
  def create
    merchant = User.find_by(id: payment_params[:merchant_id])

    if merchant.nil? || !merchant.merchant?
      return render json: { error: "Merchant not found or invalid" }, status: :not_found
    end

    amount = payment_params[:amount].to_f
    if amount <= 0
      return render json: { error: "Invalid payment amount" }, status: :unprocessable_entity
    end

    if current_user.balance < amount
      return render json: { error: "Insufficient funds" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      current_user.update!(balance: current_user.balance - amount)
      merchant.update!(balance: merchant.balance + amount)

      Transaction.create!(
        sender: current_user,
        recipient: merchant,
        amount: amount,
        message: payment_params[:message] || "Merchant payment"
      )

      render json: { message: "Payment successful", to: merchant.email, amount: amount }, status: :ok
    end
  end

  private

  def payment_params
    params.permit(:merchant_id, :amount, :message)
  end
end
