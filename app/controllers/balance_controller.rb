class BalanceController < ApplicationController
  def top_up
    from = CreditCardForm.new(top_up_params)

    if from.valid?
      current_user.update!(balance: current_user.balance + from.amount.to_f)
      render json: { message: 'Top-up successful', balance: current_user.balance }, status: :ok
    else
      render json: { errors: from.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def top_up_params
    params.permit(:card_number, :cardholder_name, :cvv, :amount)
  end
end