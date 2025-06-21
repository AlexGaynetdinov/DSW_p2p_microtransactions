class SplitParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :split_transaction
end
