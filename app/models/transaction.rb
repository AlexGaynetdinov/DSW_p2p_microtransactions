class Transaction < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :sender_cannot_be_recipient

  def sender_cannot_be_recipient
    errors.add(:recipient, "can't be the same as sender") if sender_id == recipient_id
  end
end
