require 'swagger_helper'

RSpec.describe 'api/v1/courses', type: :request do
  before do
    artem = Author.create!(name: "Artem", email: "artem@example.com")
    alexey = Author.create!(name: "Alexey", email: "alexey@example.com")
    Course.create! do |course|
      course.assign_attributes(
        title: "Course 1",
        author: artem,
        competences: [
          Competence.new(title: "competence1"),
          Competence.new(title: "competence2"),
          Competence.new(title: "competence3")
        ]
      )
    end
    Course.create! do |course|
      course.assign_attributes(
        title: "Course 2",
        author: alexey,
        competences: [
          Competence.new(title: "competence4"),
          Competence.new(title: "competence5")
        ]
      )
    end
  end

  path '/api/v1/courses' do
    get('list courses') do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        example 'application/json', :default, {
          courses: [
            {
              id: 1,
              title: "Course 1",
              description: "Description 1",
              level: "easy",
              rating: "93.57",
              enable: true,
              author: { id: 1, name: "Artem" },
              competences: [
                { id: 1, title: "competence1" },
                { id: 2, title: "competence2" },
                { id: 3, title: "competence3" }
              ]
            },
            {
              id: 2,
              title: "Course 2",
              description: "Description 2",
              level: "normal",
              rating: "70.92",
              enable: true,
              author: { id: 2, name: "Alexey" },
              competences: [
                { id: 4, title: "competence4" },
                { id: 5, title: "competence5" }
              ]
            }
          ]
        }
        run_test! do |example|
          data = JSON.parse(response.body)
          expect(data['courses'].count).to eq(2)
          expect(data['courses'].first['title']).to eq('Course 1')
          expect(data['courses'].second['author']['name']).to eq('Alexey')
        end
      end
    end

    post('create course') do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          level: { type: :string, enum: ['easy', 'normal', 'hard'] },
          rating: { type: :string, pattern: "^\d{1,3}.\d{1,2}$" },
          enabled: { type: :boolean },
          author_id: { type: :integer }
        },
        required: ['title', 'author_id']
      }
      request_body_example name: 'course', value: {
        title: 'Course',
        description: 'Description',
        level: 'easy',
        rating: '85.75',
        enabled: true,
        author_id: 1
      }

      response(201, 'successful') do
        let(:course) do
          {
            title: 'Course 3',
            description: 'Description',
            level: 'easy',
            rating: '85.75',
            enabled: true,
            author_id: Author.find_by(email: 'artem@example.com').id
          }
        end
        example 'application/json', :default, {
          id: 1,
          title: "Course",
          description: "Description",
          level: "easy",
          rating: "85.75",
          enable: true,
          author_id: 1,
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Course 3')
          expect(Course.count).to eq(3)
        end
      end

      response(400, 'bad request') do
        let(:course) { {} }
        example 'application/json', :default, {
          status: 400,
          error: "Bad Request"
        }

        run_test! do |response|
          expect(Course.count).to eq(2)
        end
      end

      response(422, 'unprocessable entity') do
        let(:course) { { title: 'Course' } }
        example 'application/json', :default, {
          author: [ "can't be blank" ],
        }

        run_test! do |response|
          expect(Author.count).to eq(2)
        end
      end
    end
  end

  path '/api/v1/courses/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    get('show course') do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:course) { Course.create!(title: 'Course 3', author_id: Author.pick(:id)) }
        let(:id) { course.id }
        example 'application/json', :default, {
          id: 1,
          title: "Course",
          description: "Description",
          level: "easy",
          rating: "85.75",
          enable: true,
          author_id: 1,
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601,
          author: { id: 1, name: "Artem" },
          competences: [
            { id: 1, title: "competence1" },
            { id: 2, title: "competence2" },
            { id: 3, title: "competence3" }
          ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Course 3')
          expect(Course.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:id) { 'not-found' }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
          expect(Course.count).to eq(2)
        end
      end
    end

    patch('update course') do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          level: { type: :string, enum: ['easy', 'normal', 'hard'] },
          rating: { type: :string, pattern: "^\d{1,3}.\d{1,2}$" },
          enabled: { type: :boolean },
          author_id: { type: :integer }
        },
        required: ['title', 'author_id']
      }
      request_body_example name: 'course', value: {
        title: 'Course',
        description: 'Description',
        level: 'easy',
        rating: '85.75',
        enabled: true,
        author_id: 1
      }

      response(200, 'successful') do
        let(:course3) { Course.create!(title: 'Course 3', author_id: Author.pick(:id)) }
        let(:id) { course3.id }
        let(:course) { { description: 'Description for course 3' } }
        example 'application/json', :default, {
          id: 1,
          title: "Course",
          description: "Description",
          level: "easy",
          rating: "85.75",
          enable: true,
          author_id: 1,
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Course 3')
          expect(data['description']).to eq('Description for course 3')
          expect(Course.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:id) { 'not-found' }
        let(:course) { { description: 'Description for course 3' } }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
          expect(Course.count).to eq(2)
        end
      end

      response(422, 'unprocessable entity') do
        let(:course3) { Course.create!(title: 'Course 3', author_id: Author.pick(:id)) }
        let(:id) { course3.id }
        let(:course) { { title: nil } }
        example 'application/json', :default, {
          title: [ "can't be blank" ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title'].first).to eq("can't be blank")
          expect(Course.count).to eq(3)
        end
      end
    end

    delete('delete course') do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'

      response(204, 'successful') do
        let(:author_id) { Author.pick(:id) }
        let(:course3) { Course.create!(title: 'Course 3', author_id: author_id) }
        let(:id) { course3.id }

        run_test! do |response|
          expect(Course.count).to eq(2)
          expect(Author.find_by!(id: author_id)).to be_present
        end
      end

      response(404, 'not found') do
        let(:id) { 'not-found' }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
          expect(Course.count).to eq(2)
        end
      end
    end
  end
end
