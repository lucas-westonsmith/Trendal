class RelatedInterest < ApplicationRecord
  belongs_to :trend
  belongs_to :count, optional: true

  validates :title, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
