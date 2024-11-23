# == Schema Information
#
# Table name: authors
#
#  id         :bigint           not null, primary key
#  bio        :text
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Author, type: :model do
  it "must present name and email" do
    author = Author.new(name: "Artem", email: "artem@example.com")
    expect(author).to be_valid
    expect(author.name).to eq("Artem")
    expect(author.email).to eq("artem@example.com")
  end
end
