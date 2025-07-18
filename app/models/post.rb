class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user
  belongs_to :group

  validates :title, presence: true
  validates :body, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_after_start

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?
    if end_at < start_at
      errors.add(:end_at, "は開始日時より後でなければなりません")
    end
  end
end
