class Group < ApplicationRecord
  has_many :posts, dependent: :destroy
end
