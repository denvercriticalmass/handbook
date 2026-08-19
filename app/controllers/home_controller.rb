class HomeController < ApplicationController
  allow_unauthenticated_access

  def show
    @ride = Ride.next
  end
end
