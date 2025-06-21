class CreateSplitParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :split_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :split_transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
