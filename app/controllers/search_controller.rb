class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @search = Search.new(params[:q])
  end
end
