module ApplicationHelper
  # Changes when the css is rebuilt, so a deploy reinstalls the worker.
  def service_worker_release
    Rails.application.assets.load_path.find("tailwind.css")&.digest || Rails.env
  end

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
