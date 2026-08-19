class Admin::GuidesController < Admin::BaseController
  def index
    authorize Guide

    @guides = Guide.by_title
  end

  def new
    authorize Guide

    @guide = Guide.new
  end

  def create
    authorize Guide

    @guide = Current.user.written_guides.new(guide_params)

    if @guide.save
      redirect_to admin_guides_path, notice: "Saved #{@guide.title}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @guide = Guide.friendly.find(params[:id])
    authorize @guide
  end

  def update
    @guide = Guide.friendly.find(params[:id])
    authorize @guide

    if @guide.update(guide_params)
      redirect_to admin_guides_path, notice: "Saved #{@guide.title}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def history
    @guide = Guide.friendly.find(params[:id])
    authorize @guide

    @history = History.new(@guide)
  end

  private

    def guide_params
      params.expect(guide: %i[ title body tag_list ])
    end
end
