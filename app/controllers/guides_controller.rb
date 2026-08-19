class GuidesController < PublicController
  def index
    @guides = Guide.by_title
  end

  def show
    @guide = Guide.friendly.find(params[:id])
  end
end
