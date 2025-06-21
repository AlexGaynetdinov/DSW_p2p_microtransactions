class AddStatusAndShareToSplitParticipants < ActiveRecord::Migration[7.1]
  def change
    add_column :split_participants, :status, :string, default: "pending"
    add_column :split_participants, :share, :decimal, null: false, default: 0
  end
end
