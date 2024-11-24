class API::V1::CoursesController < API::V1::BaseController
  before_action :set_course, only: %i[show update destroy]

  def index
    @courses = Course.includes(:author, :competences).page(params[:page]).per(50)
    render json: {
      "courses" => @courses.as_json(
        except: %i[author_id created_at updated_at],
        include: {
          author: {
            only: %i[id name]
          },
          competences: {
            only: %i[id title]
          }
        }
      )
    }
  end

  def show
    render json: @course.as_json(
      except: %i[author_id],
      include: {
        author: {
          only: %i[id name]
        },
        competences: {
          only: %i[id title]
        }
      }
    )
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      render json: @course, status: :created
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def update
    if @course.update(course_params)
      render json: @course
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy!
  end

  private

  def set_course
    @course = Course.find_by!(id: params[:id])
  end

  def course_params
    params
      .require(:course)
      .permit(
        :title, :description, :level, :rating, :enabled, :author_id
      )
  end
end
