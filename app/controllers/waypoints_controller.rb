class WaypointsController < PublicController
  def index
    @waypoints = Waypoint.grouped
    @waypoints = @waypoints.where(category: params[:category]) if Waypoint.categories.key?(params[:category])
  end

  def show
    @waypoint = Waypoint.friendly.find(params[:id])
  end
end
