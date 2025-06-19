class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key:  { to_table: :users }
      t.decimal :amount, null: false
      t.string :message

      t.timestamps
    end
  end
end
