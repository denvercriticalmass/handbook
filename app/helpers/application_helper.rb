module ApplicationHelper
  # Changes whenever the css is rebuilt, which is every deploy, so the worker
  # reinstalls and sweeps the asset cache it superseded.
  def service_worker_release
    Rails.application.assets.load_path.find("tailwind.css")&.digest.to_s
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
