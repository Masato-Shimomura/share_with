class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true    
      t.string :name, null: false                           
      t.text :explanation, null: false                      

      t.timestamps
    end

    add_index :groups, :id    
  end
end
