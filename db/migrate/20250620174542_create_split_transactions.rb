class CreateSplitTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :split_transactions do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.decimal :amount
      t.string :message

      t.timestamps
    end
  end
end
