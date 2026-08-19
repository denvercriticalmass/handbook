class GuidesController < PublicController
  def index
    @guides = Guide.by_title
  end

  def show
    @guide = Guide.find(params[:id])
  end
end
