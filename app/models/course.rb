# == Schema Information
#
# Table name: courses
#
#  id          :bigint           not null, primary key
#  description :text
#  enabled     :boolean          default(TRUE), not null
#  level       :integer
#  rating      :decimal(5, 2)
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint
#
# Indexes
#
#  index_courses_on_author_id  (author_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => authors.id)
#
class Course < ApplicationRecord
  enum :level, {
    easy: 1,
    normal: 2,
    hard: 3
  }, validate: { allow_nil: true }
  belongs_to :author, optional: true
  has_many :competences, dependent: :destroy
  validates :author, presence: true, on: :create
  validates :title, presence: true
  validates :rating, allow_nil: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
