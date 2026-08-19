Ride = Data.define(:on) do
  def self.next(on: Date.current)
    this_month = new(last_ride_day_of(on.year, on.month))

    this_month.on < on ? new(last_ride_day_of(*next_month(on))) : this_month
  end

  def self.next_month(date)
    following = date.next_month

    [ following.year, following.month ]
  end

  # prev_occurring is strictly previous, so a month ending on the ride day
  # would otherwise skip back a week.
  def self.last_ride_day_of(year, month)
    weekday = Season.for(month).weekday
    last = Date.new(year, month, -1)

    last.public_send(:"#{weekday}?") ? last : last.prev_occurring(weekday)
  end

  def winter?
    season.winter?
  end

  def gathers_at
    season.gathers_at
  end

  def rides_at
    season.rides_at
  end

  private

    def season
      Season.for(on.month)
    end
end
