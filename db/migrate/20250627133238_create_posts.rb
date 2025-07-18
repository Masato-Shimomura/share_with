class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|

      t.references :user, null: false, foreign_key: true     
      t.references :group, null: false, foreign_key: true    
      t.string :title, null: false                           
      t.text :body, null: false                              
      t.datetime :start_at, null: false                      
      t.datetime :end_at, null: false                        

      t.timestamps
    end
  end
end
