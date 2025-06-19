class CreateMoneyRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :money_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, null: false
      t.string :message
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
