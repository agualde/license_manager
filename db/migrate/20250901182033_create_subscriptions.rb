class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :number_of_licenses, null: false
      t.datetime :issued_at, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :subscriptions, [ :account_id, :product_id ], unique: true
    add_check_constraint :subscriptions, 'number_of_licenses > 0', name: 'subscriptions_number_of_licenses_must_be_positive'
  end
end
