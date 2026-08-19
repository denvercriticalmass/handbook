module ApplicationHelper
  def map_url(waypoint)
    "https://www.openstreetmap.org/?mlat=#{waypoint.latitude}&mlon=#{waypoint.longitude}" \
      "#map=18/#{waypoint.latitude}/#{waypoint.longitude}"
  end

  def suspension_warning(user)
    if user.active?
      "Suspend #{user.name}? They are signed out and can't sign back in."
    else
      "Reinstate #{user.name}?"
    end
  end
end
