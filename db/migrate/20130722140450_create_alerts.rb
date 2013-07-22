class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :name
      t.string :query
      t.string :user
      t.string :alert_type
      t.integer :frequency

      t.timestamps
    end
  end
end
