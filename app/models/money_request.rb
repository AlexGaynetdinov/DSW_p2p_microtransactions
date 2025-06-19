class MoneyRequest < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending accepted rejected] }

  validate :requester_cannot_be_recipient

  private

  def requester_cannot_be_recipient
    errors.add(:recipient, "can't be the same as requester") if requester_id == recipient_id
  end
end
