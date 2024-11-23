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
require 'rails_helper'

RSpec.describe Course, type: :model do
  it "must present title" do
    author = Author.create!(name: "Artem", email: "artem@example.com")
    course = Course.build(title: "Introduction to Ruby", author_id: author.id)
    expect(course).to be_valid
    expect(course.title).to eq("Introduction to Ruby")
  end

  it "can't create without author" do
    course = Course.create(title: "Introduction to Ruby")
    expect(course.id).to be_nil
  end

  it "can create with author and course be present after author destroy" do
    author = Author.create!(name: "Artem", email: "artem@example.com")
    course = Course.create(title: "Introduction to Ruby", author_id: author.id)
    expect(course.id).to be_present
    author.destroy!
    course.reload
    expect(Author.count).to eq(0)
    expect(Course.count).to eq(1)
    expect(course.id).to be_present
    expect(course.author_id).to be_nil
  end
end
