class ChangeAlertQueryType < ActiveRecord::Migration
  def up
    change_table :alerts do |t|
      t.change :query, :text, :limit => nil
    end
  end

  def down
    change_table :alerts do |t|
      t.change :query, :string
    end
  end
end
