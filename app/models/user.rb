class User < ApplicationRecord
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

  # Validations  
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[user admin] }

  after_initialize :set_default_balance, if: :new_record?

  def set_default_balance
    self.balance ||= 0.0
  end

  # Role checking
  def admin?
    role == 'admin'
  end
end
