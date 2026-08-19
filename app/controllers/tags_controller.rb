class TagsController < PublicController
  def show
    @tagged = Tagged.new(params[:name])
  end
end
