require 'swagger_helper'

RSpec.describe 'api/v1/competences', type: :request do
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

  path '/api/v1/courses/{course_id}/competences' do
    get('list competences') do
      tags 'Competences'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'course_id', in: :path, type: :string, description: 'course_id'
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        let(:course1) { Course.find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        example 'application/json', :default, {
          competences: [
            { id: 1, title: "competence1" },
            { id: 2, title: "competence2" },
            { id: 3, title: "competence3" }
          ]
        }

        run_test! do
          data = JSON.parse(response.body)
          expect(data['competences'].count).to eq(3)
          expect(data['competences'].first['title']).to eq('competence1')
          expect(data['competences'].last['title']).to eq('competence3')
        end
      end
    end

    post('create competence') do
      tags 'Competences'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'course_id', in: :path, type: :string, description: 'course_id'
      parameter name: :competence, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        },
        required: ['title']
      }
      request_body_example name: 'competence', value: {
        title: 'competence'
      }

      response(201, 'successful') do
        let(:course1) { Course.find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:competence) { { title: 'competence4' } }
        example 'application/json', :default, {
          id: 1,
          title: "competence4"
        }

        run_test! do |example|
          data = JSON.parse(response.body)
          expect(course1.competences.count).to eq(4)
          expect(data['title']).to eq('competence4')
        end
      end

      response(400, 'bad request') do
        let(:course1) { Course.find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:competence) { {} }
        example 'application/json', :default, {
          status: 400,
          error: "Bad Request"
        }

        run_test! do |response|
          expect(course1.competences.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:course_id) { 'not-found' }
        let(:competence) { { title: 'competence4' } }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
          expect(Competence.count).to eq(5)
        end
      end

      response(422, 'unprocessable entity') do
        let(:course1) { Course.find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:competence) { { title: nil } }
        example 'application/json', :default, {
          title: [ "can't be blank" ],
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title'].first).to eq("can't be blank")
          expect(course1.competences.count).to eq(3)
        end
      end
    end
  end

  path '/api/v1/courses/{course_id}/competences/{id}' do
    parameter name: 'course_id', in: :path, type: :string, description: 'course_id'
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show competence') do
      tags 'Competences'
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { course1.id }
        let(:id) { competence1.id }
        example 'application/json', :default, {
          id: 1, title: "competence1"
        }

        run_test! do |example|
          data = JSON.parse(response.body)
          expect(data['title']).to eq(competence1.title)
          expect(course1.competences.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { 'not-found' }
        let(:id) { competence1.id }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:id) { 'not-found' }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end
    end

    patch('update competence') do
      tags 'Competences'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :competence, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        },
        required: ['title']
      }
      request_body_example name: 'competence', value: {
        title: 'competence'
      }

      response(200, 'successful') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { course1.id }
        let(:id) { competence1.id }
        let(:competence) { { title: 'updated title in competence' }}

        run_test! do |example|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('updated title in competence')
          expect(course1.competences.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { 'not-found' }
        let(:id) { competence1.id }
        let(:competence) { { title: 'updated title in competence' }}
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:id) { 'not-found' }
        let(:competence) { { title: 'updated title in competence' }}
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end

      response(422, 'unprocessable entity') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { course1.id }
        let(:id) { competence1.id }
        let(:competence) { { title: nil } }
        example 'application/json', :default, {
          title: [ "can't be blank" ],
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title'].first).to eq("can't be blank")
          expect(course1.competences.count).to eq(3)
        end
      end
    end

    delete('delete competence') do
      tags 'Competences'
      consumes 'application/json'
      produces 'application/json'

      response(204, 'successful') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { course1.id }
        let(:id) { competence1.id }

        run_test! do |response|
          expect(course1.competences.count).to eq(2)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:competence1) { course1.competences.first }
        let(:course_id) { 'not-found' }
        let(:id) { competence1.id }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end

      response(404, 'not found') do
        let(:course1) { Course.includes(:competences).find_by!(title: "Course 1") }
        let(:course_id) { course1.id }
        let(:id) { 'not-found' }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
        end
      end
    end
  end
end
