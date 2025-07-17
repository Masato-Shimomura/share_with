class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  has_many :accepted_users, -> { where(user_groups: { status: :accepted }) }, through: :user_groups, source: :user
  has_many :posts, dependent: :destroy
  
  belongs_to :owner, class_name: "User"
  
  validates :name, presence: true
  validates :explanation, presence: true
end
