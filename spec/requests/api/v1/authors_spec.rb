require 'swagger_helper'

RSpec.describe 'api/v1/authors', type: :request do
  before do
    Author.create!(name: "Artem", email: "artem@example.com")
    Author.create!(name: "Alexey", email: "alexey@example.com")
  end

  path '/api/v1/authors' do
    get('list authors') do
      tags 'Authors'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false

      response(200, 'successful') do
        example 'application/json', :default, {
          authors: [
            {
              id: 1,
              name: 'Artem',
              email: 'artem@example.com',
              bio: nil
            },
            {
              id: 2,
              name: 'Alexey',
              email: 'alexey@example.com',
              bio: nil
            }
          ]
        }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['authors'].count).to eq(2)
          expect(data['authors'].first['name']).to eq('Artem')
        end
      end
    end

    post('create author') do
      tags 'Authors'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :author, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          bio: { type: :string }
        },
        required: ['name', 'email']
      }
      request_body_example name: 'author', value: {
        name: 'Anna',
        email: 'anna@example.com',
        bio: 'Teacher'
      }

      response(201, 'successful') do
        let(:author) { { name: 'Anna', email: 'anna@example.com', bio: 'Teacher' } }
        example 'application/json', :default, {
          id: 1,
          name: 'Anna',
          email: 'anna@example.com',
          bio: 'Teacher',
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Anna')
          expect(Author.count).to eq(3)
        end
      end

      response(400, 'bad request') do
        let(:author) { {} }
        example 'application/json', :default, {
          status: 400,
          error: "Bad Request"
        }

        run_test! do |response|
          expect(Author.count).to eq(2)
        end
      end

      response(422, 'unprocessable entity') do
        let(:author) { { name: 'Anna' } }
        example 'application/json', :default, {
          email: [ "can't be blank" ]
        }

        run_test! do |response|
          expect(Author.count).to eq(2)
        end
      end
    end
  end

  path '/api/v1/authors/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show author') do
      tags 'Authors'
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:anna) { Author.create!(name: "Anna", email: "anna@example.com") }
        let(:id) { anna.id }
        example 'application/json', :default, {
          id: 1,
          name: 'Anna',
          email: 'anna@example.com',
          bio: 'Teacher',
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Anna')
          expect(Author.count).to eq(3)
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
          expect(Author.count).to eq(2)
          expect(data['status']).to eq(404)
        end
      end
    end

    patch('update author') do
      tags 'Authors'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :author, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          bio: { type: :string }
        },
        required: ['name', 'email']
      }
      request_body_example name: 'author', value: {
        bio: 'Teacher with 5 year experience'
      }

      response(200, 'successful') do
        let(:anna) { Author.create!(name: "Anna", email: "anna@example.com") }
        let(:id) { anna.id }
        let(:author) { { bio: 'Teacher with 5 year experience' } }
        example 'application/json', :default, {
          id: 1,
          name: 'Anna',
          email: 'anna@example.com',
          bio: 'Teacher with 5 year experience',
          created_at: Time.zone.now.utc.iso8601,
          updated_at: Time.zone.now.utc.iso8601
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Anna')
          expect(data['bio']).to eq('Teacher with 5 year experience')
          expect(Author.count).to eq(3)
        end
      end

      response(404, 'not found') do
        let(:id) { 'not-found' }
        let(:author) { { bio: 'Teacher with 5 year experience' } }
        example 'application/json', :default, {
          status: 404,
          error: "Not Found"
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq(404)
          expect(Author.count).to eq(2)
        end
      end

      response(422, 'unprocessable entity') do
        let(:anna) { Author.create!(name: "Anna", email: "anna@example.com") }
        let(:id) { anna.id }
        let(:author) { { email: nil } }
        example 'application/json', :default, {
          email: [ "can't be blank" ]
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email'].first).to eq("can't be blank")
          expect(Author.count).to eq(3)
        end
      end
    end

    delete('delete author') do
      tags 'Authors'
      consumes 'application/json'
      produces 'application/json'

      response(204, 'successful') do
        let(:anna) { Author.create!(name: "Anna", email: "anna@example.com") }
        let(:id) { anna.id }

        run_test! do |response|
          expect(Author.count).to eq(2)
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
          expect(Author.count).to eq(2)
        end
      end

      response(409, 'conflict') do
        before do
          Author.destroy_all
        end
        let(:anna) { Author.create!(name: "Anna", email: "anna@example.com") }
        let(:id) { anna.id }
        example 'application/json', :default, {
          status: 409,
          error: "Conflict",
          message: "The last author cannot be deleted"
        }

        run_test! do |response|
          expect(Author.count).to eq(1)
        end
      end
    end
  end
end
