class Admin::CheatSheetsController < Admin::BaseController
  def index
    authorize CheatSheet

    @cheat_sheets = CheatSheet.by_title
  end

  def new
    authorize CheatSheet

    @cheat_sheet = CheatSheet.new
  end

  def create
    authorize CheatSheet

    @cheat_sheet = Current.user.written_cheat_sheets.new(cheat_sheet_params)

    if @cheat_sheet.save
      redirect_to admin_cheat_sheets_path, notice: "Saved #{@cheat_sheet.title}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cheat_sheet = CheatSheet.friendly.find(params[:id])
    authorize @cheat_sheet
  end

  def update
    @cheat_sheet = CheatSheet.friendly.find(params[:id])
    authorize @cheat_sheet

    if @cheat_sheet.update(cheat_sheet_params)
      redirect_to admin_cheat_sheets_path, notice: "Saved #{@cheat_sheet.title}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def history
    @cheat_sheet = CheatSheet.friendly.find(params[:id])
    authorize @cheat_sheet

    @history = History.new(@cheat_sheet)
  end

  private

    def cheat_sheet_params
      params.expect(cheat_sheet: %i[ title body tag_list ])
    end
end
