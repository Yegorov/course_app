# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

artem = Author.find_or_create_by!(email: "artem@example.com") do |author|
  author.assign_attributes(
    name: "Артем",
    bio: "Ruby on Rails developer"
  )
end

andrey = Author.find_or_create_by!(email: "andrey@example.com") do |author|
  author.assign_attributes(
    name: "Андрей",
    bio: "Front-end developer"
  )
end

anna = Author.find_or_create_by!(email: "anna@example.com") do |author|
  author.assign_attributes(
    name: "Анна",
    bio: "Manager"
  )
end

alexey = Author.find_or_create_by!(email: "alexey@example.com") do |author|
  author.assign_attributes(
    name: "Алексей",
    bio: "Manager"
  )
end

Course.find_or_create_by!(title: "Введение в Ruby") do |course|
  course.assign_attributes(
    description: "Базовый курс по языку программирования Ruby",
    level: :easy,
    rating: 93.57,
    enabled: true,
    author: artem,
    competences: [
      Competence.new(title: "ruby"),
      Competence.new(title: "rubygems"),
      Competence.new(title: "bundler")
    ]
  )
end

Course.find_or_create_by!(title: "Введение в Ruby on Rails") do |course|
  course.assign_attributes(
    description: "Базовый курс по web-фреймворку Ruby on Rails",
    level: :normal,
    rating: 95.0,
    enabled: true,
    author: artem,
    competences: [
      Competence.new(title: "backend"),
      Competence.new(title: "ruby on rails"),
      Competence.new(title: "erb"),
      Competence.new(title: "activerecord"),
      Competence.new(title: "mvc"),
      Competence.new(title: "web")
    ]
  )
end

Course.find_or_create_by!(title: "Введение в ERB") do |course|
  course.assign_attributes(
    description: "Embedded Ruby (ERB) template syntax",
    level: :normal,
    rating: 70.0,
    enabled: false,
    author: artem
  )
end

Course.find_or_create_by!(title: "Frontend-разработчик") do |course|
  course.assign_attributes(
    description: "Курс по фронтенду",
    level: :hard,
    rating: 92,
    enabled: true,
    author: andrey,
    competences: [
      Competence.new(title: "frontend"),
      Competence.new(title: "javascript"),
      Competence.new(title: "css"),
      Competence.new(title: "html"),
      Competence.new(title: "web")
    ]
  )
end

Course.find_or_create_by!(title: "Основы менеджмента") do |course|
  course.assign_attributes(
    description: "Курс по менеджменту",
    level: :normal,
    rating: 70,
    enabled: false,
    author: anna,
    competences: [
      Competence.new(title: "management"),
      Competence.new(title: "metrics"),
      Competence.new(title: "agile")
    ]
  )
end
