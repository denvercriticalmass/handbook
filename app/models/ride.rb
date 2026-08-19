Ride = Data.define(:on) do
  Season = Data.define(:weekday, :gathers_at, :rides_at)

  WINTER = Season.new(weekday: :sunday, gathers_at: "12:30pm", rides_at: "1:00pm")
  SUMMER = Season.new(weekday: :friday, gathers_at: "6:30pm", rides_at: "7:00pm")
  WINTER_MONTHS = [ 11, 12, 1, 2, 3, 4 ].freeze

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
    weekday = season_for(month).weekday
    last = Date.new(year, month, -1)

    last.public_send(:"#{weekday}?") ? last : last.prev_occurring(weekday)
  end

  def self.season_for(month)
    WINTER_MONTHS.include?(month) ? WINTER : SUMMER
  end

  def winter?
    season == WINTER
  end

  def gathers_at
    season.gathers_at
  end

  def rides_at
    season.rides_at
  end

  private

    def season
      self.class.season_for(on.month)
    end
  end
