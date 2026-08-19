class PublicController < ApplicationController
  allow_unauthenticated_access

  after_action :mark_offline_cacheable

  private

    def show_flash?
      false
    end

    # A signed-in page carries the admin nav, and the service worker would
    # hand that to whoever opens the phone next.
    def mark_offline_cacheable
      response.headers["X-Offline-Cache"] = "allowed" unless authenticated?
    end
end
