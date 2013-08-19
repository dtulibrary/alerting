class AddToAlerts < ActiveRecord::Migration
  def up
    add_column :alerts, :reference, :string
  end

  def down
    drop_column :alerts, :reference
  end
end
