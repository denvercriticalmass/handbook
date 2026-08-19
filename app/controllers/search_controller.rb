class SearchController < PublicController
  def index
    @search = Search.new(params[:q])
  end
end
