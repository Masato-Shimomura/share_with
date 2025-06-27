class CreateUserGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :user_groups do |t|

      t.references :user, null: false, foreign_key: true  
      t.references :group, null: false, foreign_key: true 
      t.integer :status, null: false, default: 0          


      t.timestamps
    end

    add_index :user_groups, [:user_id, :group_id], unique: true
  end
end
