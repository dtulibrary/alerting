class FixUserColumnName < ActiveRecord::Migration
 def change
    rename_column :alerts, :user, :user_id
  end
end
