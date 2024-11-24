class API::V1::CompetencesController < API::V1::BaseController
  before_action :set_course
  before_action :set_competence, only: %i[show update destroy]

  def index
    @competences = @course.competences.page(params[:page]).per(50)
    render json: {
      "competences" => @competences.as_json(except: %i[course_id created_at updated_at])
    }
  end

  def show
    render json: @competence
  end

  def create
    @competence = Competence.new(competence_params)
    @competence.course = @course
    if @competence.save
      render json: @competence, status: :created
    else
      render json: @competence.errors, status: :unprocessable_entity
    end
  end

  def update
    if @competence.update(competence_params)
      render json: @competence
    else
      render json: @competence.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @competence.destroy!
  end

  private

  def set_course
    @course = Course.find_by!(id: params[:course_id])
  end

  def set_competence
    @competence = @course.competences.find_by!(id: params[:id])
  end

  def competence_params
    params.require(:competence).permit(:title)
  end
end
