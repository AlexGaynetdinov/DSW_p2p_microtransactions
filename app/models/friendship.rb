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
    existing = Friendship.find_by(requester: requester, receiver: receiver) ||
               Friendship.find_by(requester: receiver, receiver: requester)
    
    if existing
      if existing.status == 'denied'
        existing.destroy # Allow resending after denial
      else
        errors.add(:base, "Friendship already exists or is pending")
      end
    end
  end
end
