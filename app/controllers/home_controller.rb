class HomeController < PublicController
  def show
    @ride = Ride.next
  end
end
