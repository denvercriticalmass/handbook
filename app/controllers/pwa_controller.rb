class PwaController < PublicController
  skip_forgery_protection

  def manifest
    render template: "pwa/manifest", formats: :json, layout: false
  end

  def service_worker
    render template: "pwa/service-worker", formats: :js, layout: false
  end
end
