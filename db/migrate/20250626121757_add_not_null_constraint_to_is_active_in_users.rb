class AddNotNullConstraintToIsActiveInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :users, :is_active, false, true
  end
end
