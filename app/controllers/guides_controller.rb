# Public and unauthenticated. Nothing here consults Current.user, so every
# visitor gets identical HTML and the service worker can cache it as-is.
class GuidesController < ApplicationController
  allow_unauthenticated_access

  def index
    @guides = Guide.by_title
  end

  def show
    @guide = Guide.find(params[:id])
  end
end
