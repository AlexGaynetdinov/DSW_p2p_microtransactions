class Friendship < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :status, inclusion: { in: %w[pending accepted denied] }
  validate :not_self
  validate :not_duplicate, on: :create

  def not_self
    errors.add(:receiver, "can't be yourself") if requester_id == receiver_id
  end

  def not_duplicate
    if Friendship.exists?(requester: requester, receiver: receiver) ||
       Friendship.exists?(requester: receiver, receiver: requester)
      errors.add(:base, "Friendship already exists or pending")
    end
  end
end
