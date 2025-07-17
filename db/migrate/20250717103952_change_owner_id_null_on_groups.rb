class ChangeOwnerIdNullOnGroups < ActiveRecord::Migration[6.1]
  def change
    change_column_null :groups, :owner_id, true
  end
end
