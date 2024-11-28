class Video < ApplicationRecord
  belongs_to :trend
  belongs_to :count, optional: true
end
