module ApplicationHelper
  def existing_tags
    ActsAsTaggableOn::Tag.pluck(:name)
  end

  def google_sign_in?
    Rails.application.credentials.dig(:google, :client_id).present?
  end

  # OmniAuth hands the query back at the callback, so the token survives Google.
  def google_sign_in_path(token: nil)
    return "/auth/google_oauth2" if token.blank?

    "/auth/google_oauth2?#{ { token: }.to_query }"
  end

  # Changes when the css is rebuilt, so a deploy reinstalls the worker.
  def service_worker_release
    Rails.application.assets.load_path.find("tailwind.css")&.digest || Rails.env
  end

  def map_url(waypoint)
    latitude, longitude = waypoint.latitude, waypoint.longitude

    "https://www.openstreetmap.org/?mlat=#{latitude}&mlon=#{longitude}#map=18/#{latitude}/#{longitude}"
  end

  def suspension_warning(user)
    if user.active?
      "Suspend #{user.name}? They are signed out and can't sign back in."
    else
      "Reinstate #{user.name}?"
    end
  end
end
