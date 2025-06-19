class CreditCardForm
  include ActiveModel::Model

  attr_accessor :card_number, :cardholder_name, :cvv, :amount

  validates :card_number, :cardholder_name, :cvv, :amount, presence: true
  validates :cvv, length: { is: 3 }, numericality: { only_integer: true }
  validate :valid_card_number
  validate :valid_amount

  def valid_card_number
    unless luhn_valid?(card_number)
      errors.add(:card_number, 'is not a valid credit card number')
    end
  end

  def valid_amount
    errors.add(:amount, 'must be positive') unless amount.to_f.positive?
  end

  def luhn_valid?(number)
    digits = number.to_s.chars.map(&:to_i)
    checksum = digits.reverse.each_with_index.sum do |digit, index|
      if index.odd?
        double = digit * 2
        double > 9 ? double - 9 : double
      else
        digit
      end
    end
    checksum % 10 == 0
  end
end