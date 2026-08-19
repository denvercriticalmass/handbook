# Every page a rider reaches without an account. An alert meant for an admin has
# no business on a page someone is reading for the meet time, so these pages
# render no flash.
class PublicController < ApplicationController
  allow_unauthenticated_access

  private

    def show_flash?
      false
    end
end
