# Public and unauthenticated, like the guides. Nothing here consults
# Current.user, so the service worker can cache what it renders as-is.
class CheatSheetsController < ApplicationController
  allow_unauthenticated_access

  def index
    @cheat_sheets = CheatSheet.by_title
  end

  def show
    @cheat_sheet = CheatSheet.find(params[:id])
  end
end
