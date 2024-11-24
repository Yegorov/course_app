class API::V1::AuthorsController < API::V1::BaseController
  before_action :set_author, only: %i[show update destroy]

  def index
    @authors = Author.page(params[:page]).per(50)
    render json: {
      "authors" => @authors.as_json(except: %i[created_at updated_at])
    }
  end

  def show
    render json: @author
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      render json: @author, status: :created
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  def update
    if @author.update(author_params)
      render json: @author
    else
      render json: @author.errors, status: :unprocessable_entity
    end
  end

  def destroy
    new_author = Author.first
    if new_author.nil?
      return render json: {
          status: 409,
          error: "The last author cannot be deleted"
      }, status: :conflict
    end
    Author.transaction do
      Course.where(author_id: @author.id).update_all(author_id: new_author.id)
      @author.destroy!
    end
  end

  private

  def set_author
    @author = Author.find_by!(id: params[:id])
  end

  def author_params
    params.require(:author).permit(:name, :email, :bio)
  end
end
