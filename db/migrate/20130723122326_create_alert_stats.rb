class CreateAlertStats < ActiveRecord::Migration
  def change
    create_table :alert_stats do |t|
      t.datetime :last_run
      t.integer :count
      t.references :alert

      t.timestamps
    end
    add_index :alert_stats, :alert_id
  end
end
