class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group

  enum status: { pending: 0, accepted: 1, declined: 2 }

  validates :user_id, uniqueness: { scope: :group_id }
end
