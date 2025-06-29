class User < ApplicationRecord

  VALID_EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}\z/
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :registerable,
         :validatable,
         :jwt_authenticatable, 
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null #No token revocation for now

  # Associations
  has_many :sent_transactions, class_name: 'Transaction', foreign_key: 'sender_id'
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'recipient_id'
  has_many :money_requests_sent, class_name: 'MoneyRequest', foreign_key: 'requester_id'
  has_many :money_requests_received, class_name: 'MoneyRequest', foreign_key: 'recipient_id'
  has_many :split_transactions, foreign_key: 'creator_id'
  has_many :split_participations, class_name: 'SplitParticipant'
  has_many :participated_splits, through: :split_participations, source: :split_transaction
  # Friendships initiated by the user
  has_many :sent_friend_requests, class_name: 'Friendship', foreign_key: 'requester_id'
  # Friendships received by the user
  has_many :received_friend_requests, class_name: 'Friendship', foreign_key: 'receiver_id'

  # Validations  
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[user admin merchant] }
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX, message: "Must use a valid email" }
  validates :password, format: { with: VALID_PASSWORD_REGEX, message: "Password must be at least 8 characters and include uppercase, lowercase, and numbers" }, if: :password_required?

  after_initialize :set_default_balance, if: :new_record?

  scope :active, -> { where(deleted: [false, nil]) }

  def soft_delete
    update(deleted: true)
  end

  def set_default_balance
    self.balance ||= 0.0
  end

  # Role checking
  def admin?
    role == 'admin'
  end
  def merchant?
    role == 'merchant'
  end

  # Accept Friendships
  def friends
    sent = Friendship.where(requester_id: id, status: 'accepted').pluck(:receiver_id)
    received = Friendship.where(receiver_id: id, status: 'accepted').pluck(:requester_id)
    User.where(id: (sent + received).uniq)
  end

  private 

  def password_required?
    new_record? || !password.nil?
  end
end
