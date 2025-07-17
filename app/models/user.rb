class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :image
  
  scope :active, -> { where(is_active: true) }

  has_many :user_groups, dependent: :destroy
  has_many :groups, -> { where(user_groups: { status: :accepted }) }, through: :user_groups
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :owned_groups, class_name: "Group", foreign_key: "owner_id", dependent: :nullify

  def active_for_authentication?
    super && is_active?
  end
  
  def inactive_message
    is_active? ? super : :inactive_account
  end

  def full_name
    "#{last_name} #{first_name}"
  end
end
