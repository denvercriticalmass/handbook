class CheatSheetsController < PublicController
  def index
    @cheat_sheets = CheatSheet.by_title
  end

  def show
    @cheat_sheet = CheatSheet.friendly.find(params[:id])
  end
end
