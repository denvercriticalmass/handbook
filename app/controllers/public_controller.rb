class PublicController < ApplicationController
  allow_unauthenticated_access

  private

    def show_flash?
      false
    end
end
