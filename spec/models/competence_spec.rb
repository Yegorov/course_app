# == Schema Information
#
# Table name: competences
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :bigint           not null
#
# Indexes
#
#  index_competences_on_course_id  (course_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
require 'rails_helper'

RSpec.describe Competence, type: :model do
  it "must present title" do
    author = Author.create!(name: "Artem", email: "artem@example.com")
    course = Course.create!(title: "Introduction to Ruby", author_id: author.id)
    competence = Competence.new(title: "Ruby", course_id: course.id)
    expect(competence).to be_valid
    expect(competence.title).to eq("Ruby")
  end
end
