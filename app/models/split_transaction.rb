class SplitTransaction < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :split_participants
  has_many :users, through: :split_participants

  validates :amount, numericality: { greater_than: 0 }
end
